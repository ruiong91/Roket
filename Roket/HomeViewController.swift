//
//  ViewController.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    let currentUser = FIRAuth.auth()?.currentUser
    
    var zeroTime = TimeInterval()
    
    var timer : Timer = Timer()
    
    var newDate = Date()
    var endDate = Date()
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var distanceTraveled = 0.0
    
    let healthManager = HealthKitManager()
    let healthKitStore = HKHealthStore()
    
    var gamesPlaying : [Game] = []
    
    var dbRef : FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Need to Enable Location")
        }
        
        // We cannot access the user's HealthKit data without specific permission.
        getHealthKitPermission()
        checkForInvitation()
        
    }
    
    //------------------------------HealthKit----------------------------//
    func getHealthKitPermission() {
        
        // Seek authorization in HealthKitManager.swift.
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            
            if authorized {
                
                // Get and set the user's height.
                self.setSteps()
                print("authorised")
            } else {
                if error != nil {
                    print(error)
                }
                print("Permission denied.")
            }
        }
    }
    
    func retrieveStepCount(startDate: Date, completion: @escaping (_ stepRetrieved: Double) -> Void) {
        
        //   Define the Step Quantity Type
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        //        //   Get the start of the day
        //        let date = NSDate()
        //        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        //        newDate = cal.startOfDay(for: date as Date)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: NSDate() as Date, options: .strictStartDate)
        let interval = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval as DateComponents)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                //  Something went Wrong
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: startDate as Date, to: self.endDate as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        print("quantity available")
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        print("Steps = \(steps)")
                        completion(steps)
                        
                    }
                }
            }
        }
        self.healthKitStore.execute(query)
        
    }
    
    func setSteps(){
        let steps = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        //Get the start of the day
        let date = NSDate()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        newDate = cal.startOfDay(for: date as Date)
        let newDateInt = Int(newDate.timeIntervalSinceReferenceDate)
        let newDateInterval = String(newDateInt)
        
        retrieveStepCount(startDate: newDate) { (steps) in
            let stepsInt = Int(steps)
            self.stepsLabel.text = String(stepsInt)
            self.dbRef.child("users").child((self.currentUser?.uid)!).child("history").child(newDateInterval).setValue(stepsInt)
        }
        
        //        retrieveDailyStepCount { (steps) in
        //            let stepsInt = Int(steps)
        //            self.stepsLabel.text = String(stepsInt)
        
        //TODO: save to database
        
        
    }
    
    
    //--------------------------CHALLENGE RESULT-------------------------//
    
    
    func getChallengeResult(){
        
        for eachGame in gamesPlaying{
            
            if let gameID = eachGame.gameID {
                
                dbRef.child("games").child(gameID).child("startDate").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let startIntervalString = snapshot.value as? String else {return}
                    let startIntervalDouble = Double(startIntervalString)
                    let startInterval = TimeInterval(startIntervalDouble!)
                    let startDate = Date(timeIntervalSinceReferenceDate: startInterval)
                    
                    
                    self.retrieveStepCount(startDate: startDate, completion: { (steps) in
                        
                        let stepsInt = Int(steps)
                        let kcalBurnt = stepsInt * 44
                        self.kcalBurntLabel.text = String(kcalBurnt)
                        
                        self.dbRef.child("games").child(gameID).child("players").child((self.currentUser?.uid)!).setValue(stepsInt)
                    })
                })
            }
        }
    }
    
    
    
    //--------------------------CHALLENGE INVITATION-------------------------//
    
    func checkForInvitation(){
        
        dbRef.child("users").child((currentUser?.uid)!).child("games").observe(.childAdded, with: { (snapshot) in
            
            let newGame = Game()
            
            let isAccepted = snapshot.value as? Bool
            if isAccepted == true {
                newGame.gameID = snapshot.key
                self.gamesPlaying.append(newGame)
            } else {
                self.askUserToAcceptGame(gameID: snapshot.key, newGame : newGame)
            }
            
            self.getChallengeResult()
            self.gamesLabel.text = String(self.gamesPlaying.count)
        })
    }
    
    func askUserToAcceptGame(gameID : String, newGame : Game){
        let alert = UIAlertController(title: "Challenge Invitation", message: "Accept the challenge!", preferredStyle: .alert)
        let accept = UIAlertAction(title: "Accept", style: .default) { (action) in
            self.handleAcceptance(gameID: gameID, newGame: newGame)
        }
        let reject = UIAlertAction(title: "Not now", style: .cancel) { (action) in
            self.handleRejection(gameID: gameID)
        }
        
        alert.addAction(accept)
        alert.addAction(reject)
        present(alert, animated: true, completion: nil)
    }
    
    func handleAcceptance(gameID : String, newGame : Game){
        dbRef.child("users").child((currentUser?.uid)!).child("games").child(gameID).setValue(true)
        dbRef.child("games").child(gameID).child("players").child((currentUser?.uid)!).setValue(0)
        gamesPlaying.append(newGame)
    }
    
    func handleRejection(gameID : String){
        dbRef.child("users").child((currentUser?.uid)!).child("games").child(gameID).removeValue()
    }
    
    func goToProfile(){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as?  SignUpViewController else { return }
        
        self.present(controller, animated: true, completion: nil)
        
        dbRef?.child("users").child((currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            let username = value?["username"] as? String ?? ""
            let userPP = value?["profilePicURL"] as? String ?? ""
            let ppUrl = URL(string: userPP)
            controller.usernameTF.text = username
            
            if let url = ppUrl {
                if let data = NSData(contentsOf: url as URL) {
                    controller.ppImageView.image = UIImage(data: data as Data)
                }
            }
        })
        
        controller.signUpBtn.setTitle("Save", for: .normal)
        controller.confirmPasswordTF.isHidden = true
        controller.passwordTF.isHidden = true
        controller.emailTF.isHidden = true
    }
    
    func goToHistory(){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as?  HistoryViewController else { return }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToRank(){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeViewController") as?  ChallengeViewController else { return }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToInvite(){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "InviteViewController") as?  InviteViewController else { return }
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var kcalBurntLabel: UILabel!
    
    @IBOutlet weak var gamesLabel: UILabel!
    
    @IBOutlet weak var image1: UIImageView!{
        didSet{
            image1.layer.cornerRadius = image1.frame.size.height/2
            image1.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var image2: UIImageView!{
        didSet{
            image1.layer.cornerRadius = image1.frame.size.height/2
            image1.clipsToBounds = true
        }
    }
    
    
    @IBOutlet weak var profileBtn: UIButton!{
        didSet{
            profileBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            profileBtn.layer.cornerRadius = 15
            profileBtn.layer.borderWidth = 2
            profileBtn.layer.borderColor = UIColor.black.cgColor
            
            profileBtn.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var historyBtn: UIButton!{
        didSet{
            historyBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            historyBtn.layer.cornerRadius = 15
            historyBtn.layer.borderWidth = 2
            historyBtn.layer.borderColor = UIColor.black.cgColor
            
            historyBtn.addTarget(self, action: #selector(goToHistory), for: .touchUpInside)
        }
    }
    
    
    @IBOutlet weak var rankBtn: UIButton!{
        didSet{
            rankBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            rankBtn.layer.cornerRadius = 15
            rankBtn.layer.borderWidth = 2
            rankBtn.layer.borderColor = UIColor.black.cgColor
            
            rankBtn.addTarget(self, action: #selector(goToRank), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var challengBtn: UIButton!{
        didSet{
            challengBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            challengBtn.layer.cornerRadius = 20
            challengBtn.layer.borderWidth = 2
            challengBtn.layer.borderColor = UIColor.black.cgColor
            
            challengBtn.addTarget(self, action: #selector(goToInvite), for: .touchUpInside)
        }
    }
    
    
}



//QUESTIONS:
//1. how to request to read > 1 health data
//2. how to create and use public func
