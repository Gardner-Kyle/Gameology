//
//  GameTableSectionViewCell.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/24/20.
//

import Foundation
import UIKit

class GameTableSectionViewCell: UITableViewCell {
    
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var favoritesBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
