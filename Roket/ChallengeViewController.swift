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
    var dbRef : FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()

        rankCollectionView.dataSource = self
        rankCollectionView.isPagingEnabled = true
        
        rankCollectionView.register(RankCollectionViewCell.cellNib, forCellWithReuseIdentifier: RankCollectionViewCell.cellIdentifier)
        getPlayersData()
        rankCollectionView.reloadData()
    }
    
    func getPlayersData(){
        
        dbRef.child("games").child("-Kf_WJg2tUQJx73wLSUk").child("players").queryOrderedByValue().observe(.childAdded, with: { (snapshot) in
            let newPlayer = Player()
            
            
            newPlayer.uid = snapshot.key
            newPlayer.score = snapshot.value as! String
            
            self.players.append(newPlayer)
            
        })
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as? RankCollectionViewCell else {return UICollectionViewCell()}
        
        let player = players[indexPath.row]
        cell.stepsLabel.text = player.score
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height)
    }
    
    
    @IBOutlet weak var rankCollectionView: UICollectionView!
    
}
