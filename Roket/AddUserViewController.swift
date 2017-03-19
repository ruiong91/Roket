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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()
        
        searchBar.delegate = self
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.register(UserTableViewCell.cellNib, forCellReuseIdentifier: UserTableViewCell.cellIdentifier)
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
    
    func done(){
        //returning to challengePage
        guard let challengePage = storyboard?.instantiateViewController(withIdentifier: "InviteViewController") as? InviteViewController else {return}
        present(challengePage, animated: true, completion: nil)
        
        challengePage.players = players
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    
    @IBOutlet weak var doneBtn: UIButton!{
        didSet{
            
            doneBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            doneBtn.layer.cornerRadius = 15
            doneBtn.layer.borderWidth = 2
            doneBtn.layer.borderColor = UIColor.black.cgColor
            
            doneBtn.addTarget(self, action: #selector(done), for: .touchUpInside)
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
        self.searchBar.endEditing(true)
        filteredUsers = allUsers
        usersTableView.reloadData()
    }
}

extension AddUserViewController : UITableViewDelegate, UITableViewDataSource {
    
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
    
    
}
