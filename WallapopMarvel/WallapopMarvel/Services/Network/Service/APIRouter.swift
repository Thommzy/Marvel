//
//  APIRouter.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Foundation

/**
 Network API router.
 - Builds requests
 - Sends request
 - Retrieves the response from the remote server.
 */
class APIRouter<EndPoint: EndPointType>: NetworkRouter {
    private var task: URLSessionTask?
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 30
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        return session
    }()

    /**
     Performs the request and retrieves the response data from the remote server
     - Parameters:
     - route: info for building the URLrequest
     - responseHandler: an objject which validates the response.
     - Returns: the Publisher with the respective decoded response and error.
     */
    func request<T>(_ route: EndPoint,
                    responseHandler: RemoteAPIResponseHandler?) -> AnyPublisher<T, NetworkError> where T: Decodable {
        do {
            let request = try buildRequest(from: route)
            NetworkLogger.log(request: request)
            return URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .tryMap { [weak self] output in
                    guard let self = self else { throw NetworkError.unknown }
                    return try self.handle(output, with: responseHandler)
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { [weak self] error in
                    guard let self = self else { return NetworkError.unknown }
                    return self.handleError(error)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.unknown).eraseToAnyPublisher()
        }
    }

    func requestWithEmptyResponse(_ route: EndPoint,
                                  responseHandler: RemoteAPIResponseHandler?) -> AnyPublisher<Void, NetworkError> {
        do {
            let request = try buildRequest(from: route)
            NetworkLogger.log(request: request)
            return URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .tryMap { [weak self] output in
                    guard let self = self else { throw NetworkError.unknown }
                    return try self.handleEmpty(output, with: responseHandler)
                }
                .mapError { error in
                    return error as? NetworkError ?? NetworkError.unknown
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.unknown).eraseToAnyPublisher()
        }
    }

    /**
     Performs the request and retrieves the response data from the remote server
     - Parameters:
     - route: info for building the URLrequest
     - responseHandler: an objject which validates the response.
     - completion: Completion handler
     - Returns: fired URLSession task
     */
    @discardableResult
    func request<T: Decodable>(_ route: EndPoint,
                               responseHandler: RemoteAPIResponseHandler?,
                               completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask? {
        do {
            let request = try buildRequest(from: route)
            NetworkLogger.log(request: request)
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                var handlerResult: Result<Void, Error> = .success(())
                if let handler = responseHandler {
                    handlerResult = handler.handleNetworkResponse(response, data: data)
                }
                switch handlerResult {
                case .success:
                    do {
                        guard let data = data else {
                            completion(.failure(NetworkError.noData))
                            return
                        }
                        NetworkLogger.log(response: response, data: data)
                        let model = try data.decodeTo(type: T.self)
                        completion(.success(model))
                    } catch {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            })
            self.task = task
        } catch {
            completion(.failure(error))
        }
        task?.resume()
        return task
    }

    private func resultHandler(_ output: URLSession.DataTaskPublisher.Output,
                               with responseHandler: RemoteAPIResponseHandler?) throws -> Result<Void, Error> {
        guard output.response is HTTPURLResponse else { throw NetworkError.noResponse("No response") }
        NetworkLogger.log(response: output.response, data: output.data)
        guard let handler = responseHandler else { throw NetworkError.noResponse("Failed to find responseHandler") }
        return handler.handleNetworkResponse(output.response, data: output.data)
    }

    private func handle(_ output: URLSession.DataTaskPublisher.Output,
                        with responseHandler: RemoteAPIResponseHandler?) throws -> Data {
        let handler = try resultHandler(output, with: responseHandler)
        switch handler {
        case .success:
            return output.data
        case let .failure(error):
            throw error
        }
    }

    private func handleEmpty(_ output: URLSession.DataTaskPublisher.Output,
                             with responseHandler: RemoteAPIResponseHandler?) throws {
        let handler = try resultHandler(output, with: responseHandler)
        switch handler {
        case .success:
            return Void()
        case let .failure(error):
            throw error
        }
    }

    private func handleError(_ error: Error) -> NetworkError {
        NetworkLogger.log(error: error)
        if let urlError = error as? URLError {
            return NetworkError.noInternetConnection(urlError.localizedDescription)
        }
        if let networkError = error as? NetworkError {
            return networkError
        }
        return NetworkError.noResponse(String(describing: error))
    }

    /**
     Builds the URLrequest
     - Parameter route: endpoint which holds all the info for building request
     - Throws: encoding error
     - Returns: ready to send URLRequest
     */
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 30.0)
        request.httpMethod = route.httpMethod.rawValue
        request.allHTTPHeaderFields = route.headers
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case let .requestParameters(bodyParameters, urlParameters):
                try configureParameters(bodyParameters: bodyParameters,
                                        urlParameters: urlParameters,
                                        request: &request)

            case let .requestParametersAndHeaders(bodyParameters,
                                                  urlParameters,
                                                  additionalHeaders):
                addAdditionalHeaders(additionalHeaders, request: &request)
                try configureParameters(bodyParameters: bodyParameters,
                                        urlParameters: urlParameters,
                                        request: &request)
            }
            return request
        } catch {
            throw error
        }
    }

    /**
     Configures the URLrequest with parameters
     - Parameters:
     - bodyParameters: represents JSON's body params
     - urlParameters: represents URL Query params
     - request: urlRequest to configure
     - Throws: encoding error
     */
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         urlParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }

    /**
     Adds additional headers to the request if needed
     - Parameters:
     - additionalHeaders: HTTPHeaders  to add
     - request: urlRequest which needs additional headers
     */
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    /// Cancels the URLSessionTask
    func cancel() {
        task?.cancel()
    }
}

extension Data {
    func decodeTo<T: Decodable>(type: T.Type,
                                strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = strategy
        return try decoder.decode(type, from: self)
    }

    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = [T](repeating: 0, count: count / MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}
