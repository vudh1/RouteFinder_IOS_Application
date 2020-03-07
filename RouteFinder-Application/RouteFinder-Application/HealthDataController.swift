//
//  HealthDataControllerViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/4/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import HealthKit


class HealthDataController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return goalList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(goalList[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        GoalLabel.text = String(goalList[row])
    }
    
    var pickerDefaultRow : Int = 0
    
    var dailyGoal : Int = 0
    var currentAcchieve : Int = 0
    var currentToGoal : Int = 0
    
    let healthStore = HKHealthStore()
    
    var getToday = false
    var getCurrent = false
    
    var goalList : [Int] = []
    
    @IBOutlet weak var DailyDistanceLabel: UILabel!
    @IBOutlet weak var CurrentAcchievementLabel: UILabel!
    @IBOutlet weak var CurrentToGoalLabel: UILabel!
    
    @IBOutlet weak var GoalLabel: UILabel!
    @IBOutlet weak var CurrentStepsLabel: UILabel!
    
    @IBOutlet weak var hideHealthInformation: UIButton!

    @IBOutlet weak var HeightLabel: UILabel!
    @IBOutlet weak var WeightLabel: UILabel!
    
    @IBOutlet weak var ChangeGoalOutlet: UIButton!
   

    @IBAction func ChangeGoalPressed(_ sender: Any) {
        
    }
    
    @IBOutlet weak var goalListPicker: UIPickerView!
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...9999{
            goalList.append(i)
        }
        

        
        getHealthInformation{
            //self.goalListPicker.selectedRow(inComponent: self.pickerDefaultRow)
        }


        HeightLabel.layer.masksToBounds = true
        HeightLabel.layer.cornerRadius = 8.0
             
        WeightLabel.layer.masksToBounds = true
        WeightLabel.layer.cornerRadius = 8.0
        
        DailyDistanceLabel.layer.masksToBounds = true
        DailyDistanceLabel.layer.cornerRadius = 8.0
        
        CurrentAcchievementLabel.layer.masksToBounds = true
        CurrentAcchievementLabel.layer.cornerRadius = 8.0
        
        CurrentToGoalLabel.layer.masksToBounds = true
        CurrentToGoalLabel.layer.cornerRadius = 8.0
        
        CurrentStepsLabel.layer.masksToBounds = true
        CurrentStepsLabel.layer.cornerRadius = 8.0
        
        
        GoalLabel.layer.masksToBounds = true
        GoalLabel.layer.cornerRadius = 8.0
        
        ChangeGoalOutlet.layer.masksToBounds = true
        ChangeGoalOutlet.layer.cornerRadius = 8.0
        
        hideHealthInformation.layer.masksToBounds = true
        hideHealthInformation.layer.cornerRadius = 8.0
        
        goalListPicker.delegate = self
        goalListPicker.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
    }
    
    //MARK: - Get Health Data
    /***************************************************************/
    func getHealthInformation(completion : @escaping() -> Void){
        getDistanceData {
                   if (self.getToday && self.getCurrent){
                       self.currentToGoal = self.dailyGoal - self.currentAcchieve
                       
                       self.DailyDistanceLabel.text = String(self.dailyGoal)
                       self.CurrentAcchievementLabel.text = String(self.currentAcchieve)
                       self.CurrentToGoalLabel.text = String(self.currentToGoal)
                       
                       self.getToday = false
                       self.getCurrent = false
                    
                    completion()
                   }
               }
            
        getUserHeight()
        getUserWeight()
             
        getTodaySteps { (result) in
                DispatchQueue.main.async {
                     let stepCount = String(Int(result))
                     self.CurrentStepsLabel.text = String(stepCount)
                 }
             }
        
    }

    //MARK: - Get Distance Data
    /***************************************************************/
    func getDistanceData(completion : @escaping () -> Void){

        let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                                    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!]
                // Check for Authorization
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
            
        if (bool) {
            self.getTodayDistance { (result) in
                DispatchQueue.main.async {
                    self.currentAcchieve = Int(round(result))
                    self.getToday = true
                    completion()
                }
            }
                        
            self.getDailyDistance{ (result) in
                DispatchQueue.main.async {
                    self.dailyGoal = Int(round(result))
                    self.getCurrent = true
                    completion()
                }
            }
            
            }
        }
    }
    
    
    func getDailyDistance(completion: @escaping (Double) -> Void){
        guard let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
           fatalError("Something went wrong retriebing quantity type distanceWalkingRunning")
       }
       
       let newdate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
       let predicateone = HKQuery.predicateForSamples(withStart: newdate, end: Date(), options: .strictStartDate)
       
       let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicateone, options: [.cumulativeSum]) { (query, statistics, error) in
           var runWalkDistance: Double = 0
           
           if error != nil {
               print("something went wrong")
           } else if let quantity = statistics?.sumQuantity() {
                runWalkDistance = quantity.doubleValue(for: HKUnit.meter()) / 365
                completion(runWalkDistance)
           }
           
       }
             healthStore.execute(query)
    }
    
    func getTodayDistance(completion: @escaping (Double) -> Void)
    {
        let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
        quantitySamplePredicate: nil,
        options: [.cumulativeSum],
        anchorDate: startOfDay,
        intervalComponents: interval)
        query.initialResultsHandler = { _, result, error in
                var resultCount = 0.0
                result!.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in

                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    resultCount = sum.doubleValue(for: HKUnit.meter())
                } // end if

                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        
        query.statisticsUpdateHandler = {
            query, statistics, statisticsCollection, error in

            // If new statistics are available
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.meter())
                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            } // end if
        }
        healthStore.execute(query)
    }
    
    //MARK: - Get Step Data
    /***************************************************************/
    func getTodaySteps(completion: @escaping (Double) -> Void)
    {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: type,
        quantitySamplePredicate: nil,
        options: [.cumulativeSum],
        anchorDate: startOfDay,
        intervalComponents: interval)
        query.initialResultsHandler = { _, result, error in
                var resultCount = 0.0
                result!.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in

                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    resultCount = sum.doubleValue(for: HKUnit.count())
                } // end if

                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        query.statisticsUpdateHandler = {
            query, statistics, statisticsCollection, error in

            // If new statistics are available
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.count())
                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            } // end if
        }
        healthStore.execute(query)
    }
    
   
    //MARK: - Get Height Data
    /***************************************************************/
    func getUserHeight() {
        // Fetch user's default height unit in inches.
        let lengthFormatter = LengthFormatter()
        lengthFormatter.unitStyle = Formatter.UnitStyle.long
        
        let heightFormatterUnit = LengthFormatter.Unit.inch
        let heightUnitString = lengthFormatter.unitString(fromValue: 10, unit: heightFormatterUnit)
        let localizedHeightUnitDescriptionFormat = NSLocalizedString("Height (%@)", comment: "")
        
        self.HeightLabel.text = String(format: localizedHeightUnitDescriptionFormat, heightUnitString)
        
        let heightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        
        // Query to get the user's latest height, if it exists.
        self.healthStore.aapl_mostRecentQuantitySampleOfType(heightType, predicate: nil) {mostRecentQuantity, error in
            if mostRecentQuantity == nil {
                NSLog("Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.")
                
                DispatchQueue.main.async {
                    self.HeightLabel.text = NSLocalizedString("Not available", comment: "")
                }
            } else {
                // Determine the height in the required unit.
                let heightUnit = HKUnit.inch()
                let usersHeight = mostRecentQuantity!.doubleValue(for: heightUnit)
                
                // Update the user interface.
                DispatchQueue.main.async {
                    self.HeightLabel.text = NumberFormatter.localizedString(from: usersHeight as NSNumber, number: NumberFormatter.Style.none)
                }
            }
        }
    }
    
    //MARK: - Get Weight Data
    /***************************************************************/
    func getUserWeight() {
        // Fetch the user's default weight unit in pounds.
        let massFormatter = MassFormatter()
        massFormatter.unitStyle = .long
        
        let weightFormatterUnit = MassFormatter.Unit.pound
        let weightUnitString = massFormatter.unitString(fromValue: 10, unit: weightFormatterUnit)
        let localizedWeightUnitDescriptionFormat = NSLocalizedString("Weight (%@)", comment: "")
        
        self.WeightLabel.text = String(format:localizedWeightUnitDescriptionFormat, weightUnitString)
        
        // Query to get the user's latest weight, if it exists.
        let weightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        
        self.healthStore.aapl_mostRecentQuantitySampleOfType(weightType, predicate: nil) {mostRecentQuantity, error in
            if mostRecentQuantity == nil {
                NSLog("Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.")
                
                DispatchQueue.main.async {
                    self.WeightLabel.text = NSLocalizedString("Not available", comment: "")
                }
            } else {
                // Determine the weight in the required unit.
                let weightUnit = HKUnit.pound()
                let usersWeight = mostRecentQuantity!.doubleValue(for: weightUnit)
                
                // Update the user interface.
                DispatchQueue.main.async {
                    self.WeightLabel.text = NumberFormatter.localizedString(from: usersWeight as NSNumber, number: .none)
                }
            }
        }
    }

}


extension HKHealthStore {
    
    // Fetches the single most recent quantity of the specified type.
    func aapl_mostRecentQuantitySampleOfType(_ quantityType: HKQuantityType, predicate: NSPredicate?, completion: ((HKQuantity?, Error?)->Void)?) {
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [timeSortDescriptor]) {query, results, error in
            if results == nil {
                completion?(nil, error)
                
                return
            }
            
            if completion != nil {
                // If quantity isn't in the database, return nil in the completion block.
                let quantitySample = results!.first as? HKQuantitySample
                let quantity = quantitySample?.quantity
                
                completion!(quantity, error)
            }
        }
        
        self.execute(query)
    }
    
}

