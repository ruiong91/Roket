//
//  HistoryViewController.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class HistoryViewController: UIViewController, UITableViewDataSource {
    
    var discountDayBy : Int = 0
    var history : [History] = []
    
    var zeroTime = TimeInterval()
    
    var timer : Timer = Timer()
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var distanceTraveled = 0.0
    
    let healthManager = HealthKitManager()
    let healthKitStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        historyTableView.dataSource = self
        
        for i in 0...20 {
            
            retrieveStepCount(completion: { (steps) in
                
                self.history.sort(by: { (a, b) -> Bool in
                    a.date! > b.date!
                })
                
                self.historyTableView.reloadData()
            })
        }
    }
    
    func retrieveStepCount(completion: @escaping (_ stepRetrieved: Double) -> Void) {
        
        //   Define the Step Quantity Type
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        //   Get the start of the day
        
        let date = NSDate()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let startDate = cal.startOfDay(for: date as Date)
        let newDate = cal.date(byAdding: .day, value: discountDayBy, to: (startDate as? Date)!)!
        let endDate = cal.date(byAdding: .hour, value: 24, to: newDate)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: endDate! as Date, options: [.strictEndDate,.strictEndDate])
        let interval = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval as DateComponents)
        self.discountDayBy -= 1
        
        
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                print(error)
                //  Something went Wrong
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: newDate as Date, to: endDate! as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let newHistory = History()
                        
                        
                        let steps = quantity.doubleValue(for: HKUnit.count())
                    
                        newHistory.date = newDate
                        newHistory.steps = String(steps)
                        self.history.append(newHistory)
                        print(newDate)
                        print(endDate)
                        print("Steps = \(steps)")
                        completion(steps)
                    }
                }
            }
        }
        self.healthKitStore.execute(query)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return history.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let aHistory = history[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        cell.textLabel?.text = dateFormatter.string(from: aHistory.date!)
        cell.detailTextLabel?.text = aHistory.steps
        
        return cell
    }
    
    @IBOutlet weak var historyTableView: UITableView!
    
}
