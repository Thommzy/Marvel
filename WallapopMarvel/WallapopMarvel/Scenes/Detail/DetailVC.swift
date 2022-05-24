//
//  DetailVC.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

class DetailVC: UIViewController {
    private lazy var customScrollView = with(UIScrollView()) {_ in }
    private lazy var contentView = with(UIView()) {_ in }
    private lazy var imgView = with(UIImageView()) {
        $0.backgroundColor = .red
        $0.contentMode = .scaleAspectFill
    }
    private lazy var descriptionLabel = with(UILabel()) {
        $0.sizeToFit()
        $0.textColor = .systemBackground
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
    }
    private lazy var comicsLabel = with(UILabel()) {
        $0.sizeToFit()
        $0.textColor = .systemBackground
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
    }
    private lazy var seriesLabel = with(UILabel()) {
        $0.sizeToFit()
        $0.textColor = .systemBackground
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
    }
    private lazy var storiesLabel = with(UILabel()) {
        $0.sizeToFit()
        $0.textColor = .systemBackground
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .label
    }
    func setup(with data: MarvelCharacterDataResult) {
        guard let comicsAvailable = data.comics?.available else { return }
        guard let seriesAvailable = data.series?.available else { return }
        guard let storiesAvailable = data.stories?.available else { return }
        guard let unwrappedPath = data.thumbnail?.path else { return }
        guard let unwrappedExtension = data.thumbnail?.thumbnailExtension?.rawValue else { return }
        descriptionLabel.text = data.resultDescription
        comicsLabel.text = "Comics Availabvle: \(comicsAvailable)"
        seriesLabel.text = "Series Available: \(seriesAvailable)"
        storiesLabel.text = "Stories Available: \(storiesAvailable)"
        imgView.convertUrlToImage(path: unwrappedPath, imgVariant: "/portrait_xlarge.", extensions: unwrappedExtension)
        setupCustomScrollView()
        setupContentView()
        setupImgView()
        setupDescriptionLabel()
        setupComicsLabel()
        setupSeriesLabel()
        setupStoriesLabel()
    }
}

private extension DetailVC {
    func setupCustomScrollView() {
        self.view.addSubview(customScrollView)
        customScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    func setupContentView() {
        self.customScrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.customScrollView)
            make.width.equalTo(self.customScrollView)
        }
    }
    func setupImgView() {
        self.contentView.addSubview(self.imgView)
        imgView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.right.equalTo(self.contentView)
            make.height.equalTo(self.customScrollView)
        }
    }
    func setupDescriptionLabel() {
        self.contentView.addSubview(self.descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(20)
            make.right.equalTo(self.contentView).offset(-20)
            make.top.equalTo(self.imgView.snp.bottom).offset(10)
        }
    }
    func setupComicsLabel() {
        self.contentView.addSubview(self.comicsLabel)
        comicsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(20)
            make.right.equalTo(self.contentView).offset(-20)
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(10)
        }
    }
    func setupSeriesLabel() {
        self.contentView.addSubview(self.seriesLabel)
        seriesLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(20)
            make.right.equalTo(self.contentView).offset(-20)
            make.top.equalTo(self.comicsLabel.snp.bottom).offset(10)
        }
    }
    func setupStoriesLabel() {
        self.contentView.addSubview(self.storiesLabel)
        storiesLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(20)
            make.right.equalTo(self.contentView).offset(-20)
            make.bottom.equalTo(self.contentView)
            make.top.equalTo(self.seriesLabel.snp.bottom).offset(10)
        }
    }
}
