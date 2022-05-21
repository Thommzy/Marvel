//
//  NetworkLogger.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation
import os.log

// swiftlint:disable line_length
/// Logs the network requests and responses
enum NetworkLogger {
    static func log(request: URLRequest) {
        var data: String {
            guard let data = request.httpBody else { return "--" }
            return String(data: data, encoding: .utf8) ?? ""
        }
        let logString = "\(request.url?.absoluteString ?? "--")\nheaders:\(request.allHTTPHeaderFields ?? [:])\ndata:\(data)"
        os_log("Request: %{PRIVATE}@", log: .network, type: .info, logString)
    }

    static func log(response: URLResponse?, data: Data?) {
        guard let httpURLResponse = response as? HTTPURLResponse else { return }
        os_log("Status Code: %{PRIVATE}d", log: .network, type: .info, httpURLResponse.statusCode)
        if let data = data {
            NetworkLogger.log(responseData: data)
        }
    }

    static func log(error: Error) {
        os_log("Error: %{PRIVATE}@", log: .network, type: .error, error.localizedDescription)
    }

    private static func log(responseData data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return }
            os_log("Response json: %{PRIVATE}@", log: .network, type: .info, json)
        } catch {
            os_log("RESPONSE DATA CANNOT BE CONVERTED TO JSON", log: .network, type: .info)
        }
    }
}

// swiftlint:enable line_length
