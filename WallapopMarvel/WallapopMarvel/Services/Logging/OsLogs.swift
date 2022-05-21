//
//  OsLogs.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation
import os.log

enum LogCategory: String {
    case network = "[Network]"
}

extension OSLog {
    private static var subsystem: String { Bundle.main.bundleIdentifier ?? "" }

    // MARK: Logs

    static let network = OSLog(subsystem: subsystem, category: LogCategory.network.rawValue)
}
