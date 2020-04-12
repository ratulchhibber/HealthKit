//
//  HealthKitAssistant.swift
//  HealthApp
//
//  Created by Ratul Chhibber on 17/03/20.
//  Copyright © 2020 Ratul Chhibber. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitAssistant {
    
    static let shared = HealthKitAssistant()
    
    let store = HKHealthStore()
    
    func getHealthKitPermission(completion: @escaping (Bool)-> Void) {
        
        guard
            HKHealthStore.isHealthDataAvailable(),
            let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                completion(false)
                return
        }
        
        store.requestAuthorization(toShare: [stepsCount], read: [stepsCount]) { (success, error) in
            
            guard error == nil else {
                print("Error- \(error?.localizedDescription ?? "")")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    //MARK: - Get Recent step Data
    func getMostRecentStep(for sampleType: HKQuantityType,
                           completion: @escaping (_ stepRetrieved: Int, _ stepAll : [[String : String]]) -> Void) {
        
        let mostRecentPredicate =  HKQuery
                                   .predicateForSamples(withStart: Date.distantPast,
                                                        end: Date(),
                                                        options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let stepQuery = HKStatisticsCollectionQuery(quantityType: sampleType,
                                                    quantitySamplePredicate: mostRecentPredicate,
                                                    options: .separateBySource,
                                                    anchorDate: Date.distantPast,
                                                    intervalComponents: interval)
        
        stepQuery.initialResultsHandler = { query, results, error in
            
            guard
                error == nil,
                let myResults = results else { return }
            
            var stepsData = [[String:String]]()
            var steps = Int()
            stepsData.removeAll()
            
            myResults.enumerateStatistics(from: Date.distantPast, to: Date()) {
                statistics, stop in
                
                guard let quantity = statistics.sumQuantity() else { return }
                                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy"
                    dateFormatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                    dateFormatter.timeZone = NSTimeZone.local
                    
                    var tempDic = [String : String]()
                    let endDate = statistics.endDate
                    
                    steps = Int(quantity.doubleValue(for: HKUnit.count()))
                    print("Step count = \(steps)")
                    tempDic = [
                        "enddate" : "\(dateFormatter.string(from: endDate))",
                        "steps"   : "\(steps)"
                    ]
                    stepsData.append(tempDic)
            }
            completion(steps, stepsData.reversed())
        }
        HKHealthStore().execute(stepQuery)
    }
}
