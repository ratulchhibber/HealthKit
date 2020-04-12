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
            let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let weight = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
                completion(false)
                return
        }
        
        store.requestAuthorization(toShare: [height], read: [stepsCount, height, weight]) { (success, error) in
            
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


extension HealthKitAssistant {
    
    enum QuantityType {
        case height, weight
    }
    
    func read(for type: QuantityType, completion: @escaping (_ value: String?) -> Void) {
        let identifier: HKQuantityTypeIdentifier = type == .height ? .height : .bodyMass
        
        guard let customType = HKSampleType
                               .quantityType(forIdentifier: identifier) else {
                                return
        }
        let query = HKSampleQuery(sampleType: customType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample{
                if type == .weight {
                    let value = Int((result.quantity.doubleValue(for: HKUnit.gram()))/1000)
                    completion(String(value))
                } else if type == .height {
                    let value = Int((result.quantity.doubleValue(for: HKUnit.inch())))
                    completion(String(value))
                }
            } else {
                completion(nil)
            }
        }
        HKHealthStore().execute(query)
    }
    
    func saveHeight(for value: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        if let type = HKSampleType
                      .quantityType(forIdentifier: HKQuantityTypeIdentifier.height),
            let val = Double(value) {
            
            let date = Date()
            let quantity = HKQuantity(unit: HKUnit.inch(), doubleValue: val)
            let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
            HKHealthStore().save(sample, withCompletion: { (success, error) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
}
