//
//  RemoteAPIResponseHandler.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation

protocol RemoteAPIResponseHandler {
    func handleNetworkResponse(_ response: URLResponse?, data: Data?) -> Result<Void, Error>
}
