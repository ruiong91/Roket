//
//  ChallengeViewController.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ChallengeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var players : [Player] = []
    var gamesPlaying : [Game] = []
    var currentGame : Game?
    
    var dbRef : FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()
        
        rankCollectionView.dataSource = self
        rankCollectionView.isPagingEnabled = true
        
        rankCollectionView.register(RankCollectionViewCell.cellNib, forCellWithReuseIdentifier: RankCollectionViewCell.cellIdentifier)
        rankCollectionView.register(GameCollectionViewCell.cellNib, forCellWithReuseIdentifier: GameCollectionViewCell.cellIdentifier)
        
        currentGame = gamesPlaying[0]
        
    }
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            currentGame = gamesPlaying[indexPath.item]
            rankCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var noOfItems = 0
        
        if section == 0 {
            noOfItems = gamesPlaying.count
        } else {
            if let validPlayerCount = currentGame?.players.count {
                noOfItems = validPlayerCount
            }
        }
        
        return noOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if indexPath.section == 0 {
            guard let validCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as? GameCollectionViewCell else {return UICollectionViewCell()}
            
            validCell.gameLabel.text = "Challenge \(indexPath.item+1)"
            
            cell = validCell
            
        } else {
            guard let validCell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as? RankCollectionViewCell else {return UICollectionViewCell()}
            
            if let player = currentGame?.players[indexPath.item] {
                
                validCell.nameLabel.text = player.username
                validCell.stepsLabel.text = String(player.score)
                validCell.rankLabel.text = String(indexPath.item+1)
                
                if let url = player.ppUrl {
                    if let data = NSData(contentsOf: url as URL) {
                        validCell.ppImageView.image = UIImage(data: data as Data)
                    }
                }
                
                cell = validCell
            }
        }
        //let player = players[indexPath.row]
        //cell.stepsLabel.text = String(player.score)
        
        return cell
    }
    
    
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        return CGSize(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height)
    //    }
    
    
    @IBOutlet weak var rankCollectionView: UICollectionView!
    
}
