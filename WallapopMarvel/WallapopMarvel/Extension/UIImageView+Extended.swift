//
//  UIImageView+Extended.swift
//  WallapopMarvel
//
//  Created by Timothy  on 24/05/2022.
//

import UIKit
import Kingfisher

extension UIImageView {
    func convertUrlToImage(path: String, imgVariant: String, extensions: String) {
        let urlString = path + imgVariant + extensions
        let url = URL(string: urlString)
        self.kf.setImage(with: url)
    }
}
