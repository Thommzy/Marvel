//
//  NetworkError.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation

public protocol UnknownErrorHaving: Error {
    static var unknown: Self { get }
}

public enum NetworkError: UnknownErrorHaving, Equatable {
    case badURL(_ error: String)
    case apiError(code: Int, error: String)
    case customError
    case invalidJSON(_ error: String)
    case unauthorized(code: Int, error: String)
    case badRequest(code: Int, error: String)
    case serverError(code: Int, error: String)
    case noResponse(_ error: String)
    case unableToParseData(_ error: String)
    case noInternetConnection(_ error: String)
    case unknown
    case noData
}
