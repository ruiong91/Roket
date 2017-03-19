//
//  InviteViewController.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class InviteViewController: UIViewController, UINavigationControllerDelegate {
    
    let currentUser = FIRAuth.auth()?.currentUser
    
    var dbRef : FIRDatabaseReference!
    var players : [User] = []
    
    var startDate = Date()
    //let transitionManager = TransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()
        // self.navigationController?.delegate = self
    }
    
    //    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    //        return transitionManager
    //    }
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // this gets a reference to the screen that we're about to transition to
        let toViewController = segue.destination as! AddUserViewController
        
        // instead of using the default transition animation, we'll ask
        // the segue to use our custom TransitionManager object to manage the transition animation
        toViewController.transitioningDelegate = self
        toViewController.modalPresentationStyle = .custom
    }
    
    func animationStart(){
        guard let addFriendController = storyboard?.instantiateViewController(withIdentifier: "AddUserViewController") as? AddUserViewController else {return}
        
        present(addFriendController, animated: true, completion: nil)
    }
    
    //    func presentNextPage(){
    //        guard let addFriendController = storyboard?.instantiateViewController(withIdentifier: "AddUserViewController") as? AddUserViewController else {return}
    //        navigationController?.pushViewController(addFriendController, animated: true)
    //        addFriendController.transitioningDelegate = self.transitionManager
    //        addFriendController.modalPresentationStyle = .custom
    //
    ////        self.addChildViewController(addFriendController)
    ////        view.addSubview(addFriendController.view)
    ////        addFriendController.didMove(toParentViewController: self)
    ////
    ////        performSegue(withIdentifier: "slideUp", sender: Any?.self)
    //    }
    
    func startChallenge(){
        //save game & player to firebase
        dbRef = FIRDatabase.database().reference()
        let autoidRef = dbRef.child("games").childByAutoId()
        let gameStartDate = Date()
        let gameStartDateInt = Int(gameStartDate.timeIntervalSinceReferenceDate)
        let gameStartInterval = String(gameStartDateInt)
        print("this is \(gameStartDate)")
        
        for each in players {
            let playerUID = each.uid
            dbRef.child("users").child(each.uid).child("games").child(autoidRef.key).setValue(false)
            
        }
        dbRef.child("users").child((currentUser?.uid)!).child("games").child(autoidRef.key).setValue(true)
        dbRef.child("games").child(autoidRef.key).child("players").child((currentUser?.uid)!).setValue(0)
        
        dbRef.child("games").child(autoidRef.key).child("startDate").setValue(gameStartInterval)
    }
    
    func backToHome(){
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {return}
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var invitedImageView: UIImageView!
    
    
    @IBOutlet weak var addFriendBtn: UIButton!{
        didSet{
            
            addFriendBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            addFriendBtn.layer.cornerRadius = 15
            addFriendBtn.layer.borderWidth = 2
            addFriendBtn.layer.borderColor = UIColor.black.cgColor
            
            addFriendBtn.addTarget(self, action: #selector(animationStart), for: .touchUpInside)
        }
    }
    
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

extension InviteViewController : UIViewControllerTransitioningDelegate{
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionManager()
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionManager()
    }
    
}
