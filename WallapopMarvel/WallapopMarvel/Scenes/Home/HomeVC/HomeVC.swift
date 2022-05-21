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
        subscriptions = [
        
        ]
    }
    
    func setupPreData() {
        viewModel.timeStamp.send(1653117571321)
        viewModel.apiKey.send("0702af7759fed52f09d5becfe3156deb")
        viewModel.hash.send("78e72675f178d55e3911ed7c730851f7")
    }
}
