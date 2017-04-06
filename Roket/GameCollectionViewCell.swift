//
//  GameCollectionViewCell.swift
//  Roket
//
//  Created by Rui Ong on 04/04/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit

class GameCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "gameCell"
    static let cellNib = UINib(nibName: "GameCollectionViewCell", bundle: Bundle.main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var gameLabel: UILabel!
}
