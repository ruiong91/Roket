//
//  CustomHeaderCell.swift
//  Roket
//
//  Created by Rui Ong on 03/04/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit

class CustomHeaderCell: UITableViewCell {
    
    static let cellIdentifier = "CustomHeaderCell"
    static let cellNib = UINib(nibName: "CustomHeaderCell", bundle: Bundle.main)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
}



