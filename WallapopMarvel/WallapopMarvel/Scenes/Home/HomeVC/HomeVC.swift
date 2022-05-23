//
//  HomeVC.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Combine
import UIKit
import SnapKit

protocol HomeVCDelegate: AnyObject {
    func didMoveTodetail()
}

class HomeVC: UIViewController {
    private lazy var baseView = with(UIView()) {
        $0.backgroundColor = .systemBackground
    }
    private lazy var marvelTableView = with(UITableView()) {
        $0.register(MarvelTableViewCell.self,
                    forCellReuseIdentifier: MarvelTableViewCell.reuseIdentifier)
        $0.separatorStyle = .none
    }
    weak var homeCoordinateDelegate: HomeVCDelegate?
    var viewModel: HomeViewModelling!
    private var subscriptions = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreData()
        bind(to: viewModel)
        setupBaseView()
        setupMarvelTableView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear.send()
    }
}

private extension HomeVC {
    func bind(to viewModel: HomeViewModelling) {
        subscriptions = [
            viewModel
                .dataSouceUpdated
                .sink { [weak self] in
                    DispatchQueue.main.async {
                        self?.marvelTableView.reloadData()
                    }
                }]
    }
    func setupPreData() {
        title = "Marvel"
        viewModel.timeStamp.send(Config.timeStamp)
        viewModel.apiKey.send(Config.apiKey)
        viewModel.hash.send(Config.hash)
    }
    func setupBaseView() {
        view.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    func setupMarvelTableView() {
        baseView.addSubview(marvelTableView)
        marvelTableView.delegate = self
        marvelTableView.dataSource = self
        marvelTableView.snp.makeConstraints { make in
            make.edges.equalTo(baseView)
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MarvelTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? MarvelTableViewCell else {
            fatalError("Failed to deque a cell")
        }
        cell.configure(with: viewModel.displayModelForCell(at: indexPath))
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        homeCoordinateDelegate?.didMoveTodetail()
    }
}
