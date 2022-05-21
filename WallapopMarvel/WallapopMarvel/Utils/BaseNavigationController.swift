//
//  BaseNavigationController.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

class BaseNavigationController: UINavigationController {
    // Return the visible child view controller which determines the status bar style.
    override var childForStatusBarStyle: UIViewController? { return visibleViewController }
}
