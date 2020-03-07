//
//  MainViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/6/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import HealthKit

class MainViewController: UIViewController {
    var newGoalSet : Int = 0
    
    var dailyGoal : Int = 0
    var currentAcchieve : Int = 0
    var currentToGoal : Int = 0
    let healthStore = HKHealthStore()
    var getToday = false
    var getCurrent = false
    
    @IBOutlet weak var GetLocationsOutlet: UIButton!

    @IBAction func GetLocationsPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToHealthController", sender: self)
    }
    
    @IBOutlet weak var GetHealthInformation: UIButton!

    @IBAction func GetHealthInformation(_ sender: Any) {
        performSegue(withIdentifier: "goToHealthDataController", sender: self)
    }

    
    //MARK: - Segue
    /***************************************************************/

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHealthController"{
            let destinationVC = segue.destination as! HealthController
            
            destinationVC.reccomendGoal = String(currentToGoal)
        }
        
        if segue.identifier == "goToHealthDataController"{
            let destinationVC = segue.destination as! HealthDataController
            
            destinationVC.pickerDefaultRow = dailyGoal
        }
    }
    
    @IBAction func unwindToMainController(_sender : UIStoryboardSegue){
        if _sender.source is HealthDataController{
            if let senderVC = _sender.source as? HealthDataController{
                newGoalSet = senderVC.currentToGoal
            }
        }
    }

    /***************************************************************/

    override func viewDidLoad() {
        super.viewDidLoad()

        GetLocationsOutlet.layer.masksToBounds = true
        GetLocationsOutlet.layer.cornerRadius = 8.0
           
        GetHealthInformation.layer.masksToBounds = true
        GetHealthInformation.layer.cornerRadius = 8.0
        
        getHealthInformation {}
       }

       override func didReceiveMemoryWarning() {
              super.didReceiveMemoryWarning()
       }
    

    ///
    //MARK: - Get Health Data
    /***************************************************************/
    func getHealthInformation(completion : @escaping () -> Void){
        getDistanceData {
                   if (self.getToday && self.getCurrent){
                       self.currentToGoal = self.dailyGoal - self.currentAcchieve
                        completion()
                       
                       self.getToday = false
                       self.getCurrent = false
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
    

}
