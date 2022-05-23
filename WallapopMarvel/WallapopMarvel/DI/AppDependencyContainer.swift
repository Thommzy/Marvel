//
//  AppDependencyContainer.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import Swinject
import UIKit

class AppDependencyContainer {
    private lazy var appDIContainer: Container = {
        Container { container in
            // MARK: HomeRepo

            // MARK: HomeRemoteAPI

            container.register(HomeRemoteAPI.self) { _ in
                HomeAPI(homeRouter: APIRouter<HomeEndpoint>(),
                        homeResponseHandler: HomeAPIResponseHandler())
            }
            // MARK: HomeCoordinator
            container.register(HomeCoordinator.self) { (_, router: RouterType) -> HomeCoordinator in
                let homeDIContainer: HomeDIContainer = HomeDIContainer(parentContainer: container)
                return HomeCoordinator(router: router,
                                       homeVCFactory: homeDIContainer.makeHomeCoordinator,
                                       detailVCFactory: homeDIContainer.makeDetailVC)
            }
            // MARK: AppCoordinator
            container.register(AppCoordinator.self) { resolver in
                let rootVC = UIViewController()
                let navVC = BaseNavigationController(rootViewController: rootVC)
                navVC.navigationBar.isTranslucent = true
                let homeCoordinatorFactory: (RouterType) -> HomeCoordinator = { router in
                    resolver.resolve(HomeCoordinator.self, argument: router)!
                }
                let appRouter = Router(navigationController: navVC)
                return AppCoordinator(router: appRouter,
                                      homeCoordinatorFactory: homeCoordinatorFactory)
            }
            .inObjectScope(.weak)
        }
    }()
    func makeAppCoordinator() -> AppCoordinator { appDIContainer.resolve(AppCoordinator.self)! }
}
