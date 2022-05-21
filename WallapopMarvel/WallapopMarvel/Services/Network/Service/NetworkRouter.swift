//
//  NetworkRouter.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Foundation

protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType
    func request<T>(_ route: EndPoint,
                    responseHandler: RemoteAPIResponseHandler?) -> AnyPublisher<T, NetworkError> where T: Decodable
    @discardableResult
    func request<T: Decodable>(_ route: EndPoint,
                               responseHandler: RemoteAPIResponseHandler?,
                               completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask?
    func cancel()
}
