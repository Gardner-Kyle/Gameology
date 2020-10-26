//
//  GameVideoCollectionViewCell.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/24/20.
//

import Foundation
import UIKit

class GameVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var btn: UIButton!

    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
