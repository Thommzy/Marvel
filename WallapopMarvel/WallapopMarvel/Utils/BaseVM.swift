//
//  BaseVM.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Foundation

protocol BaseViewModelling {
    var didTapAskATutor: PassthroughSubject<Void, Never> { get }
    var sessionText: CurrentValueSubject<String, Never> { get }
    var networkError: PassthroughSubject<Void, Never> { get }
    var unauthorizedError: PassthroughSubject<Void, Never> { get }
    var apiError: PassthroughSubject<String, Never> { get }
    var successResponse: PassthroughSubject<MarvelCharacter, Never> { get }
}

class BaseViewModel {
    var didTapAskATutor = PassthroughSubject<Void, Never>()
    var sessionText = CurrentValueSubject<String, Never>("")
    let networkError = PassthroughSubject<Void, Never>()
    let unauthorizedError = PassthroughSubject<Void, Never>()
    let apiError = PassthroughSubject<String, Never>()
    var subscriptions = Set<AnyCancellable>()
    var successResponse = PassthroughSubject<MarvelCharacter, Never>()
}

