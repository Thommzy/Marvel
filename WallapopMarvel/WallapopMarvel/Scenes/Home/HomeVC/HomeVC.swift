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
    func didMoveTodetail(model: MarvelCharacterDataResult)
}

class HomeVC: UIViewController {
    private lazy var baseView = with(UIView()) {
        $0.backgroundColor = .clear
    }
    private lazy var marvelTableView = with(UITableView()) {
        $0.register(MarvelTableViewCell.self,
                    forCellReuseIdentifier: MarvelTableViewCell.reuseIdentifier)
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.keyboardDismissMode = .onDrag

    }
    private lazy var customLoader = with(UIActivityIndicatorView()) {
        $0.style = .large
        $0.startAnimating()
    }
    private lazy var searchBar = with(UISearchBar()) {
        $0.searchBarStyle = .prominent
        $0.placeholder = " Search..."
        $0.sizeToFit()
        $0.isTranslucent = false
        $0.backgroundImage = UIImage()
        navigationItem.titleView = $0
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
        setupCustomLoader()
        setupSearchBar()
        viewModel.viewDidLoad.send()
    }
}

private extension HomeVC {
    func bind(to viewModel: HomeViewModelling) {
        subscriptions = [
            viewModel
                .dataSouceUpdated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                        self?.customLoader.stopAnimating()
                        self?.marvelTableView.reloadData()
                },
            viewModel
                .onSelect
                .sink(receiveValue: { [weak self] model in
                    self?.navigationItem.backBarButtonItem = UIBarButtonItem(title: model.name,
                                                                             style: .plain,
                                                                             target: nil,
                                                                             action: nil)
                    self?.homeCoordinateDelegate?.didMoveTodetail(model: model)
                }),
            searchBar
                .searchTextField
                .setupSearchBarListener()
                .compactMap {$0}
                .assign(to: viewModel.searchStr)
        ]
    }
    func setupPreData() {
        title = HomeView.title
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = .systemBackground
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
    func setupCustomLoader() {
        marvelTableView.addSubview(customLoader)
        customLoader.snp.makeConstraints { make in
            make.centerY.equalTo(marvelTableView)
            make.centerX.equalTo(marvelTableView)
        }
    }

    func setupSearchBar() {
        searchBar.delegate = self
    }
}

extension HomeVC: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
        viewModel.didSelect.send(indexPath)
    }
}
