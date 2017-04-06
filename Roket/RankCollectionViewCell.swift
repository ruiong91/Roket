//
//  RankCollectionViewCell.swift
//  Roket
//
//  Created by Rui Ong on 19/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit

class RankCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "rankCell"
    static let cellNib = UINib(nibName: "RankCollectionViewCell", bundle: Bundle.main)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var ppImageView: UIImageView!{
        didSet{
            ppImageView.layer.cornerRadius = ppImageView.frame.size.height/2
            ppImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
}
