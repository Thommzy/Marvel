//
//  HomeAPIResponseHandler.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation

class HomeAPIResponseHandler: RemoteAPIResponseHandler {
    func handleNetworkResponse(_ response: URLResponse?, data: Data?) -> Result<Void, Error> {
        guard let response = response as? HTTPURLResponse else { return .failure(NetworkError.unknown) }

        switch response.statusCode {
        case 200 ... 299:
            return .success(())
        case 400:
            return .failure(NetworkError.badRequest(code: response.statusCode, error: "Bad request"))
//        case 422:
//            guard let data = data else { return .failure(NetworkError.unknown) }
//            do {
//                let errorModel = try data.decodeTo(type: ErrorModel.self)
//                let message = errorModel.message
//                return .failure(NetworkError.apiError(code: response.statusCode,
//                                                      error: message))
//            } catch {
//                return .failure(NetworkError.apiError(code: response.statusCode,
//                                                      error: "You have 0 Session left."))
//            }
        case 401:
            return .failure(NetworkError.unauthorized(code: response.statusCode, error: "Unauthorized"))
        case 501 ... 599:
            return .failure(NetworkError.serverError(code: response.statusCode, error: "Internal server error occured"))
        default:
            return .failure(NetworkError.unknown)
        }
    }
}
