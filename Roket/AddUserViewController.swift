//
//  AddUserViewController.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddUserViewController: UIViewController, AddPlayerDelegate {
    
    var dbRef : FIRDatabaseReference!
    var allUsers : [User] = []
    var filteredUsers : [User] = []
    var players : [User] = []
    
    var timer : Timer?
    var counter = 86400
    var countdown = "24 : 00"
    
    let currentUser = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.register(UserTableViewCell.cellNib, forCellReuseIdentifier: UserTableViewCell.cellIdentifier)
        usersTableView.register(CustomHeaderCell.cellNib, forCellReuseIdentifier: CustomHeaderCell.cellIdentifier)
        usersTableView.estimatedRowHeight = 80
        usersTableView.rowHeight = UITableViewAutomaticDimension
        
        navigationController?.navigationItem.title = "Steps"
        
        
        fetchUsers()
    }
    
    func fetchUsers(){
        
        
        dbRef.child("users").observe(.childAdded, with: { (snapshot) in
            
            guard let value = snapshot.value as? [String : Any] else {
                return
            }
            let newUser = User(withDictionary: value)
            newUser.uid = snapshot.key
            self.fetchProfilePic(key: newUser.uid, user: newUser)
        })
    }
    
    func fetchProfilePic(key : String, user : User){
        dbRef?.child("users").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            let userPP = value?["profilePicURL"] as? String ?? ""
            user.ppUrl = URL(string: userPP)
            
            self.allUsers.append(user)
            self.filteredUsers = self.allUsers
            self.usersTableView.reloadData()
        })
    }
    
    func addPlayers(indexPath : IndexPath){
        let userAdded = filteredUsers[indexPath.row]
        
        players.append(userAdded)
        
        //        if let url = userAdded.ppUrl {
        //            if let data = NSData(contentsOf: url as URL) {
        //                challengePage.invitedImageView.image = UIImage(data: data as Data)
        //
        //            }
        //        }
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
       
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        
        return String(format: "%02d : %02d", hours, minutes)
    }
    
    func countdownTimer(){
        
        self.counter -= 1
        
        if self.counter < 0 {
            self.timer?.invalidate()
        }
        else {
            countdown = self.timeFormatted(totalSeconds: self.counter)
            print(countdown)
        }
    }
    
    func startChallenge(){
        //save game & player to firebase
        dbRef = FIRDatabase.database().reference()
        let autoidRef = dbRef.child("games").childByAutoId()
        let gameStartDate = Date()
        let gameStartDateInt = Int(gameStartDate.timeIntervalSinceReferenceDate)
        let gameStartInterval = String(gameStartDateInt)
        print("this is \(gameStartDate)")
        
        self.timer = Timer.init(fireAt: gameStartDate, interval: 1.0, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: true)
        //(timeInterval: 1.0, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
        
        for each in players {
            let playerUID = each.uid
            dbRef.child("users").child(each.uid).child("games").child(autoidRef.key).setValue(false)
            
        }
        dbRef.child("users").child((currentUser?.uid)!).child("games").child(autoidRef.key).setValue(true)
        dbRef.child("games").child(autoidRef.key).child("players").child((currentUser?.uid)!).setValue(0)
        
        dbRef.child("games").child(autoidRef.key).child("startDate").setValue(gameStartInterval)
        
        backToHome()
    }
    
    func backToHome(){
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {return}
        
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    
    @IBOutlet weak var homeBtn: UIButton!
        {
        didSet{
            
            homeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            homeBtn.layer.cornerRadius = 15
            homeBtn.layer.borderWidth = 2
            homeBtn.layer.borderColor = UIColor.black.cgColor
            
            homeBtn.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        }
    }
    
    
    @IBOutlet weak var startBtn: UIButton!{
        didSet{
            
            startBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            startBtn.layer.cornerRadius = 15
            startBtn.layer.borderWidth = 2
            startBtn.layer.borderColor = UIColor.black.cgColor
            
            startBtn.addTarget(self, action: #selector(startChallenge), for: .touchUpInside)
        }
    }
    
    
}

extension AddUserViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = usersTableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as? UserTableViewCell else {return UITableViewCell()}
        
        let user = filteredUsers[indexPath.row]
        
        cell.nameLabel.text = user.username
        cell.detailLabel.text = user.email
        cell.currentIndexPath = indexPath
        cell.delegate = self
        
        if let url = user.ppUrl {
            if let data = NSData(contentsOf: url as URL) {
                cell.ppImageView.image = UIImage(data: data as Data)
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = usersTableView.dequeueReusableCell(withIdentifier: "CustomHeaderCell") as? CustomHeaderCell else {return UITableViewCell()}
        
        cell.searchBar.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 430
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var sectionHeaderHeight: CGFloat = 385
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        }
        else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
        }
        
    }
}
extension AddUserViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            resetSearch()
        } else {
            filteredUsers = allUsers.filter({( user : User) -> Bool in
                return user.username?.lowercased().range(of: searchText.lowercased()) != nil
            })
            
            usersTableView.reloadData()
            
        }
    }
    
    func resetSearch(){
        //self.searchBar.endEditing(true)
        filteredUsers = allUsers
        usersTableView.reloadData()
    }
}

