//
//  HomeCoordinator.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
    func didAuthorize()
}

class HomeCoordinator: Coordinator<DeepLink> {
    lazy var homeVC: HomeVC = {
        let homeVC = self.homeVCFactory()
        homeVC.homeCoordinateDelegate = self
        homeVC.navigationItem.hidesBackButton = true
        return homeVC
    }()
    weak var delegate: HomeCoordinatorDelegate?
    private let homeVCFactory: () -> HomeVC
    init(router: RouterType,
         homeVCFactory: @escaping () -> HomeVC) {
        self.homeVCFactory = homeVCFactory
        super.init(router: router)
    }
    override func start(with link: DeepLink?) {
        guard link != nil else {
            router.setRootModule(self, hideBar: false, animated: true)
            return
        }
    }

    deinit {
        debugPrint("\(self) is dead")
    }
    // default to the router's navigationController
    override func toPresentable() -> UIViewController { homeVC }
}

extension HomeCoordinator: HomeVCDelegate {
    func didMoveTodetail() {}
}
