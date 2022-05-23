//
//  With.swift
//  WallapopMarvel
//
//  Created by Timothy  on 23/05/2022.
//

import Foundation

public func with<T: AnyObject>(_ item: T, update: (T) -> Void) -> T {
    update(item); return item
}
