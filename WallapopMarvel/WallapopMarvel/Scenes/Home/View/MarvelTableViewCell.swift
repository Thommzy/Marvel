//
//  MarvelTableViewCell.swift
//  WallapopMarvel
//
//  Created by Timothy  on 23/05/2022.
//

import UIKit
import SnapKit
import Kingfisher

class MarvelTableViewCell: UITableViewCell {
    private lazy var baseView = with(UIView()) {
        $0.backgroundColor = .systemGray
        $0.layer.cornerRadius = 10
    }
    private lazy var leftView = with(UIView()) {
        $0.backgroundColor = .clear
    }
    private lazy var rightView = with(UIView()) {
        $0.backgroundColor = .clear
    }
    private lazy var baseStackView = with(UIStackView(
        arrangedSubviews: [leftView,
                           rightView])
    ) {
        $0.axis = .horizontal
        $0.spacing = 5
        $0.distribution = .fill
    }
    private lazy var imgView = with(UIImageView()) {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 50
        $0.layer.masksToBounds = true
    }
    private lazy var nameLabel = with(UILabel()) {
        $0.textColor = .label
    }
    private lazy var descriptionLabel = with(UILabel()) {
        $0.textColor = .label
        $0.numberOfLines = 0
    }
    private lazy var seriesLabel = with(UILabel()) {
        $0.backgroundColor = .black
    }
    private lazy var detailStackView = with(UIStackView(
        arrangedSubviews: [nameLabel,
                           descriptionLabel])
    ) {
        $0.axis = .vertical
        $0.spacing = 5
        $0.distribution = .fill
    }
    func configure(with model: MarvelCharacterDataResult) {
        nameLabel.text = model.name
        descriptionLabel.text = model.resultDescription
        guard let unwrappedPath = model.thumbnail?.path else { return }
        guard let unwrappedExtension = model.thumbnail?.thumbnailExtension?.rawValue else { return }
        imgView.convertUrlToImage(path: unwrappedPath, imgVariant: "/portrait_xlarge.", extensions: unwrappedExtension)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBaseView()
        setupBaseStackView()
        setupLeftView()
        setupImgView()
        setupDetailStackView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        descriptionLabel.text = nil
        imgView.image = nil
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

private extension MarvelTableViewCell {
    func setupBaseView() {
        contentView.addSubview(baseView)
        contentView.backgroundColor = .clear
        baseView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-15)
            make.top.equalTo(contentView).offset(5)
            make.bottom.equalTo(contentView).offset(-5)
        }
    }
    func setupBaseStackView() {
        baseView.addSubview(baseStackView)
        baseStackView.snp.makeConstraints { make in
            make.edges.equalTo(baseView)
        }
    }
    func setupLeftView() {
        leftView.snp.makeConstraints { make in
            make.width.equalTo(110)
        }
    }
    func setupImgView() {
        leftView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.centerX.equalTo(leftView)
            make.centerY.equalTo(leftView)
        }
    }
    func setupDetailStackView() {
        rightView.addSubview(detailStackView)
        detailStackView.snp.makeConstraints { make in
            make.left.equalTo(rightView).offset(8)
            make.right.equalTo(rightView).offset(-8)
            make.top.equalTo(rightView).offset(8)
            make.bottom.equalTo(rightView).offset(-8)
        }
    }
}
