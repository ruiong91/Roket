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
    
    var players : [User] = []
    var dbRef : FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()

        rankCollectionView.isPagingEnabled = true
        
        rankCollectionView.register(RankCollectionViewCell.cellNib, forCellWithReuseIdentifier: RankCollectionViewCell.cellIdentifier)
        
        rankCollectionView.reloadData()
    }
    
    func getPlayersData(){
        
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as? RankCollectionViewCell else {return UICollectionViewCell()}
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height)
    }
    
    
    @IBOutlet weak var rankCollectionView: UICollectionView!
    
}
