//
//  HomeVC.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit
import Combine

protocol HomeVCDelegate: AnyObject {
    func didMoveTodetail()
}

class HomeVC: UIViewController {
    weak var homeCoordinateDelegate: HomeVCDelegate?
    var viewModel: HomeViewModelling!
    private var subscriptions = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        setupPreData()
        bind(to: viewModel)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear.send()
    }
}

private extension HomeVC {
    func bind(to viewModel: HomeViewModelling) {
        subscriptions = []
    }
    func setupPreData() {
        viewModel.timeStamp.send(Config.timeStamp)
        viewModel.apiKey.send(Config.apiKey)
        viewModel.hash.send(Config.hash)
    }
}
