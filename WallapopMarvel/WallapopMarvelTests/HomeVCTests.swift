//
//  HomeVCTests.swift
//  WallapopMarvelTests
//
//  Created by Timothy  on 24/05/2022.
//

import XCTest
@testable import WallapopMarvel

class HomeVCTests: XCTestCase {
    var sut: HomeVC!
    override func setUpWithError() throws {
        sut = HomeVC()
    }
    override func tearDownWithError() throws {
        sut = nil
    }
    func testDefaultState() {}
}
