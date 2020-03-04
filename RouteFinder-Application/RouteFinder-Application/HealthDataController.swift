//
//  HealthDataControllerViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/4/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import HealthKit

class HealthDataController: UIViewController {
    var goalReccomend : Int = 0
    let healthStore = HKHealthStore()

    
    @IBOutlet weak var DailyDistanceLabel: UILabel!
    
    @IBOutlet weak var AdjustGoalOutlet: UIButton!
    
    @IBAction func AdjustGoalPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToHealthController", sender: self)

    }
    
    
    @IBOutlet weak var GetDailyDistanceOutlet: UIButton!
    
    @IBAction func GetDailyDistancePressed(_ sender: Any) {
        DailyDistanceLabel.text = String(goalReccomend)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        AdjustGoalOutlet.layer.masksToBounds = true
        AdjustGoalOutlet.layer.cornerRadius = 8.0
        
        GetDailyDistanceOutlet.layer.masksToBounds = true
        GetDailyDistanceOutlet.layer.cornerRadius = 8.0
        
        getHealthData {
            
        }
    }
    
    func getHealthData( completion : @escaping () -> Void){
        let allTypes = Set([
                                               HKSampleType.quantityType(forIdentifier: .height)!,
                                               HKSampleType.quantityType(forIdentifier: .bodyMass)!,
                                               HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
                           
                           healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                               if !success {
                                   print("Read Write Auth Error")
                                   return
                               }
                           }
                           // Do any additional setup after loading the view.
                           
                           guard let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                               fatalError("Something went wrong retriebing quantity type distanceWalkingRunning")
                           }
                           
                           let newdate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
                           let predicate = HKQuery.predicateForSamples(withStart: newdate, end: Date(), options: .strictStartDate)
                           
                           let avgRunWalkquery = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
                               var runWalkDistance: Double = 0
                               
                               if error != nil {
                                   print("something went wrong")
                               } else if let quantity = statistics?.sumQuantity() {
                                   runWalkDistance = quantity.doubleValue(for: HKUnit.mile())
                                   runWalkDistance = runWalkDistance/365
                               }

                               
                               
                               self.goalReccomend = Int(runWalkDistance*1.6*1000)
                               print("RunWalkDistance: \(runWalkDistance)")
                               print("self.goalReccomend: \(self.goalReccomend)")
                                
                               completion()

                           }
            healthStore.execute(avgRunWalkquery)
        
    }
             


    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHealthController"{
            let destinationVC = segue.destination as! HealthController
            
            destinationVC.reccomendGoal = String(goalReccomend)
        }
    }
}
