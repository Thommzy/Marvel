//
//  WindowRouter.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

protocol WindowRouterType: AnyObject {
    var window: UIWindow { get }
    init(window: UIWindow)
    func setRootModule(_ module: Presentable)
}

final class WindowRouter: NSObject, WindowRouterType {
    unowned let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func setRootModule(_ module: Presentable) {
        let viewController = module.toPresentable()
        window.rootViewController = viewController
    }
}
