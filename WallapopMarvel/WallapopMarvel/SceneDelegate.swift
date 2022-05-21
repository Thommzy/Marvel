//
//  SceneDelegate.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let appDependencyContainer = AppDependencyContainer()
    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        configureNavigation(windowScene: windowScene)
    }
    func configureNavigation(windowScene: UIWindowScene) {
        appCoordinator = appDependencyContainer.makeAppCoordinator()
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        window.rootViewController = appCoordinator.toPresentable()
        window.makeKeyAndVisible()
        self.window = window
        appCoordinator.start()
    }
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    func sceneWillResignActive(_ scene: UIScene) {
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
