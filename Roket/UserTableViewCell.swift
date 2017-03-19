//
//  UserTableViewCell.swift
//  Roket
//
//  Created by Rui Ong on 18/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit

protocol AddPlayerDelegate : class {
    func addPlayers(indexPath : IndexPath)
}

class UserTableViewCell: UITableViewCell {
    
    
    
    static let cellIdentifier = "UserTableViewCell"
    static let cellNib = UINib(nibName: "UserTableViewCell", bundle: Bundle.main)
    
    var currentIndexPath = IndexPath()
    weak var delegate : AddPlayerDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handleAddBtn(){
        delegate?.addPlayers(indexPath: currentIndexPath)
        addBtn.setTitle("✓", for: .normal) 
    }
    
    @IBOutlet weak var ppImageView: UIImageView!{
        didSet{
            ppImageView.layer.cornerRadius = ppImageView.frame.size.height/2
            ppImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!{
        didSet{
            addBtn.addTarget(self, action: #selector(handleAddBtn), for: .touchUpInside)
        }
    }
}
