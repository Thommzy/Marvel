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
    var viewDidLoad: PassthroughSubject<Void, Never> { get }
    var numberOfRows: Int { get }
    func displayModelForCell(at indexPath: IndexPath) -> MarvelCharacterDataResult
    var searchStr: CurrentValueSubject<String?, Never> { get }
    var dataSouceUpdated: PassthroughSubject<Void, Never> { get }
    var didSelect: PassthroughSubject<IndexPath, Never> { get }
    var onSelect: AnyPublisher<MarvelCharacterDataResult, Never> { get }
}

class HomeViewModel: BaseViewModel, HomeViewModelling {
    var timeStamp = CurrentValueSubject<Int, Never>(0)
    var apiKey = CurrentValueSubject<String?, Never>(nil)
    var hash = CurrentValueSubject<String, Never>("")
    var viewDidLoad = PassthroughSubject<Void, Never>()
    var dataSouceUpdated = PassthroughSubject<Void, Never>()
    let searchStr = CurrentValueSubject<String?, Never>(nil)
    var didSelect = PassthroughSubject<IndexPath, Never>()
    var onSelect: AnyPublisher<MarvelCharacterDataResult, Never> { _didSelect.eraseToAnyPublisher() }
    private var _didSelect = PassthroughSubject<MarvelCharacterDataResult, Never>()

    // MARK: - Properties
    private let homeRepository: HomeRepository
    private var backupDataSource = [MarvelCharacterDataResult]()
    private var dataSource = [MarvelCharacterDataResult]() {
        didSet { dataSouceUpdated.send() }
    }

    private let userDefaults = UserDefaults.standard

    var numberOfRows: Int { dataSource.count }
    // MARK: - Methods

    init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
        super.init()
        bindOutput()
    }
    func displayModelForCell(at indexPath: IndexPath) -> MarvelCharacterDataResult {
        return dataSource[indexPath.row]
    }

    private func bindOutput() {
        viewDidLoad
            .sink { [weak self] in
                self?.triggerAPI.send()
            }
            .store(in: &subscriptions)
        getSavedData()
        getMarvelList()
            .sink { networkError in
                print(networkError)
            } receiveValue: { [unowned self] res in
                guard let results = res.data?.results else { return  }
                dataSource = results
                backupDataSource = results
                setDataToStorage(result: results)
            }
            .store(in: &subscriptions)
        searchStr
            .compactMap { $0 }
            .sink { [weak self] searchStr in
                self?.searchString(searchText: searchStr)
            }
            .store(in: &subscriptions)
        didSelect.map { [unowned self] in self.dataSource[$0.row] }
            .assign(to: _didSelect)
            .store(in: &subscriptions)
    }
    private func setDataToStorage(result: [MarvelCharacterDataResult]) {
        do {
            try self.userDefaults.setObject(result, forKey: "marvelList")
        } catch {
            print(error.localizedDescription, "Error")
        }
    }
    private func getSavedData() {
        do {
            let marvelList = try userDefaults.getObject(forKey: "marvelList",
                                                        castTo: [MarvelCharacterDataResult].self)
            dataSource = marvelList
            backupDataSource = marvelList
        } catch {
            print(error.localizedDescription, "Error")
        }
    }

    private func getMarvelList() -> AnyPublisher<MarvelCharacter, NetworkError> {
        let homeRepository = homeRepository
        return triggerAPI.withLatestFrom(timeStamp,
                                         apiKey.compactMap {$0},
                                         hash) {
            $1
        }
                                         .setFailureType(to: NetworkError.self)
                                         .flatMap { output in
                                             return homeRepository.marvelList(with: output.0,
                                                                              apiKey: output.1,
                                                                              hash: output.2,
                                                                              limit: 50)
                                         }
                                         .eraseToAnyPublisher()
    }
    private func searchString(searchText: String) {
        dataSource = searchText.isEmpty ?
        backupDataSource : backupDataSource.filter { $0.name.range(of: searchText, options: .caseInsensitive) != nil }
        debugPrint("dataSource", dataSource)
    }
}
