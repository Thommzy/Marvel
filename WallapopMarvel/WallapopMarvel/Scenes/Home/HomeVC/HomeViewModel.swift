//
//  HomeViewModel.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import CombineExt
import Foundation

protocol HomeViewModelling: BaseViewModelling {
    var timeStamp: CurrentValueSubject<Int, Never> { get }
    var apiKey: CurrentValueSubject<String?, Never> { get }
    var hash: CurrentValueSubject<String, Never> { get }
    var viewDidAppear: PassthroughSubject<Void, Never> { get }
}

class HomeViewModel: BaseViewModel, HomeViewModelling {
    var timeStamp = CurrentValueSubject<Int, Never>(0)
    var apiKey = CurrentValueSubject<String?, Never>(nil)
    var hash = CurrentValueSubject<String, Never>("")
    var viewDidAppear = PassthroughSubject<Void, Never>()

    // MARK: - Properties
    private let homeRepository: HomeRepository

    // MARK: - Methods

    init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
        super.init()
        bindOutput()
    }

    private func bindOutput() {
        viewDidAppear
            .sink { [weak self] in
                self?.didTapAskATutor.send()
            }
            .store(in: &subscriptions)

        getMarvelList()
            .sink { networkError in
                print(networkError)
            } receiveValue: { res in
                print(res.data?.results.count, "mama-->>")
                self.successResponse.send(res)
            }
            .store(in: &subscriptions)
    }

    private func getMarvelList() -> AnyPublisher<MarvelCharacter, NetworkError> {
        let homeRepository = homeRepository
        return didTapAskATutor.withLatestFrom(timeStamp,
                                              apiKey.compactMap {$0},
                                              hash) {
            $1
        }
        .setFailureType(to: NetworkError.self)
        .flatMap { output in
            return homeRepository.marvelList(with: output.0,
                                             apiKey: output.1,
                                             hash: output.2)
        }
        .eraseToAnyPublisher()
    }
}
