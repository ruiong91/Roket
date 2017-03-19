//
//  HealthKitManager.swift
//  Roket
//
//  Created by Rui Ong on 18/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class HealthKitManager : NSObject {
    
    let healthKitStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((_ success: Bool, _ error: NSError?) -> Void)!) {
        
        // State the health data type(s) we want to read from HealthKit.
        let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        
        // State the health data type(s) we want to write from HealthKit.
        // NOT USING THIS
        let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
        
        // Just in case OneHourWalker makes its way to an iPad...
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        // Request authorization to read and/or write the specific data.
        
        healthKitStore.requestAuthorization(toShare: healthDataToWrite, read: healthDataToRead) { (success, error) -> Void in
            if completion != nil {
                completion?(success, error as NSError?)
            }
        }
    }
    
    
    
    
}
