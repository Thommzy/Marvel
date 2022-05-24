//
//  HomeEndpoint.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Foundation

enum HomeEndpoint: EndPointType {
    case getMarvelList(urlParameters: Parameters)
}

extension HomeEndpoint {
    var environmentBaseURL: String { Config.baseEndPoint }
    var version: String { Versions.one }
    var paths: String { Path.character }

    var baseURL: URL {
        guard let url = URL(string: "\(environmentBaseURL)\(version)") else {
            fatalError("failed to configure base URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .getMarvelList:
            return paths
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getMarvelList:
            return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case let .getMarvelList(urlParameters):
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: urlParameters)
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .getMarvelList:
            return ["Content-Type": "application/json"]
        }
    }
}
