//
//  HomeRemoteAPI.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Foundation

protocol HomeRemoteAPI {
    func getMarvelList(with urlParameters: Parameters) -> AnyPublisher<MarvelCharacter, NetworkError>
}

struct HomeAPI: HomeRemoteAPI {
    private let homeRouter: APIRouter<HomeEndpoint>
    private let homeResponseHandler: RemoteAPIResponseHandler

    init(homeRouter: APIRouter<HomeEndpoint>,
         homeResponseHandler: RemoteAPIResponseHandler) {
        self.homeRouter = homeRouter
        self.homeResponseHandler = homeResponseHandler
    }

    func getMarvelList(with urlParameters: Parameters) -> AnyPublisher<MarvelCharacter, NetworkError> {
        return homeRouter
            .request(.getMarvelList(urlParameters: urlParameters),
                     responseHandler: homeResponseHandler)
    }
}
