//
//  HomeCoordinator.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
    func didStartApp()
}

class HomeCoordinator: Coordinator<DeepLink> {
    lazy var homeVC: HomeVC = {
        let homeVC = self.homeVCFactory()
        homeVC.homeCoordinateDelegate = self
        homeVC.navigationItem.hidesBackButton = true
        return homeVC
    }()
    lazy var detailVC: DetailVC = {
        let detailVC = self.detailVCFactory()
        detailVC.navigationItem.hidesBackButton = false
        return detailVC
    }()
    weak var delegate: HomeCoordinatorDelegate?
    private let homeVCFactory: () -> HomeVC
    private let detailVCFactory: () -> DetailVC
    init(router: RouterType,
         homeVCFactory: @escaping () -> HomeVC,
         detailVCFactory: @escaping () -> DetailVC) {
        self.homeVCFactory = homeVCFactory
        self.detailVCFactory = detailVCFactory
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
    func didMoveTodetail(model: MarvelCharacterDataResult) {
        moveToDetailVC(model: model)
    }
}

extension HomeCoordinator {
    func moveToDetailVC(model: MarvelCharacterDataResult) {
        detailVC.setup(with: model)
        router.push(detailVC, animated: true, completion: nil)
    }
}
