//
//  HomeRepository.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Foundation

protocol HomeRepository {
    func marvelList(with timeStamp: Int, apiKey: String, hash: String, limit: Int) -> AnyPublisher<MarvelCharacter, NetworkError>
}

class HomeRepo: HomeRepository {
    let homeAPI: HomeRemoteAPI

    private var subscriptions = Set<AnyCancellable>()

    init(homeAPI: HomeRemoteAPI) {
        self.homeAPI = homeAPI
    }
    func marvelList(with timeStamp: Int, apiKey: String, hash: String, limit: Int) -> AnyPublisher<MarvelCharacter, NetworkError> {
        let homeAPI = homeAPI
        return homeAPI
            .getMarvelList(with: ["ts": timeStamp,
                                  "apikey": apiKey,
                                  "hash": hash,
                                  "limit": limit])
    }
}
