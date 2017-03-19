//
//  ViewController.swift
//  Roket
//
//  Created by Rui Ong on 19/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class ViewController: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
}
