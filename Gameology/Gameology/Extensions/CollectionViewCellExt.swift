//
//  CollectionViewCellExt.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/25/20.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    func makeFancy() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor(white: 0.7, alpha: 1).cgColor
        self.contentView.layer.masksToBounds = true

    }
}
