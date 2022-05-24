//
//  HomeDIContainer.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Swinject

class HomeDIContainer {
    private let container: Container
    // MARK: OtpVC
    init(parentContainer: Container) {
        self.container = Container(parent: parentContainer) { container in
            // MARK: HomeRepo

            container.register(HomeRepository.self) { resolver in
                HomeRepo(homeAPI: resolver.resolve(HomeRemoteAPI.self)!)
            }
            .inObjectScope(.container)

            container.register(HomeVC.self) { resolver in
                let homeVC = HomeVC()
                homeVC.viewModel = resolver.resolve(HomeViewModelling.self)!
                return homeVC
            }
            container.register(HomeViewModelling.self) { resolver in
                return HomeViewModel(homeRepository: resolver.resolve(HomeRepository.self)!)
            }

            container.register(DetailVC.self) { _ in
                let detailVC = DetailVC()
//                homeVC.viewModel = resolver.resolve(HomeViewModelling.self)!
                return detailVC
            }
        }
    }
    func makeHomeCoordinator() -> HomeVC { container.resolve(HomeVC.self)! }
    func makeDetailVC() -> DetailVC { container.resolve(DetailVC.self)! }
}
