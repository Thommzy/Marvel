//
//  HTTPTask.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation
public typealias HTTPHeaders = [String: String]

enum HTTPTask {
    case request
    case requestParameters(bodyParameters: Parameters?, urlParameters: Parameters?)
    case requestParametersAndHeaders(bodyParameters: Parameters?,
                                     urlParameters: Parameters?,
                                     additionHeaders: HTTPHeaders?)
}
