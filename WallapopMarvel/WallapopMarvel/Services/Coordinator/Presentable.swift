//
//  Presentable.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

protocol Presentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    func toPresentable() -> UIViewController { self }
}
