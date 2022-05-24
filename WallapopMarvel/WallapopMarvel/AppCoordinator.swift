//
//  AppCoordinator.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

enum DeepLink {
    case auth
}

import Combine
import UIKit
/**
 The main coordinator of the app.
 Here we decide which flow to start first.
 If the user was already logged in ->  It starts the tabBar coordinator.
 If not -> AuthorizationCoordinator.
 */
class AppCoordinator: Coordinator<DeepLink> {
    // MARK: - Properties

    private let homeCoordinatorFactory: (RouterType) -> HomeCoordinator

    // MARK: - Methods

    init(router: RouterType,
         homeCoordinatorFactory: @escaping (RouterType) -> HomeCoordinator) {
        self.homeCoordinatorFactory = homeCoordinatorFactory
        super.init(router: router)
    }

    override func start(with link: DeepLink?) {
       goToHomeScreen()
    }
}

// MARK: - Navigation

extension AppCoordinator {
    func goToHomeScreen() {
        childCoordinators.removeAll()
        let coordinator = homeCoordinatorFactory(router)
        addChild(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {
    func didStartApp() {
        goToHomeScreen()
    }
}
