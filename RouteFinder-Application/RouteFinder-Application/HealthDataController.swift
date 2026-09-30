//
//  HealthDataControllerViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/4/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import HealthKit

let LOVE_SCORE = 2 // a type that is loved
let TAP_SCORE = 1 // a type that is checked
let CHECK_SCORE = 4 // a location that is checked

let REFRESH_TIME = 5
let MAX_DIGITS = 5
let MAX_RADIUS = 1000
let MAX_DIFF_FROM_DISTANCE = 500
let MIN_DISTANCE = 1
let TRAVEL_MODE = "walking"
let MAX_CELL = 25
let MAX_DIRECTION_SEARCH = 50

let LOCATION_TYPE = [
                        "aquarium",
                        "art_gallery",
                        "bakery",
                        "bar",
                        "bus_station",
                        "book_store",
                        "gas_station",
                        "grocery_or_supermarket",
                        "gym",
                        "library",
                        "movie_theater",
                        "museum",
                        "park",
                        "post_office",
                        "restaurant",
                        "shopping_mall",
                        "store",
                        "tourist_attraction",
                        "university",
                        "zoo"]

let DEFAULT_RATING = [
"aquarium" : 0 ,
"art_gallery" : 0,
"bakery" : 0,
"bar" : 0,
"bus_station" : 0,
"book_store" : 0,
"gas_station": 0,
"grocery_or_supermarket": 0,
"gym": 0,
"library": 0,
"movie_theater": 0,
"museum": 0,
"park": 0,
"post_office": 0,
"restaurant": 0,
"shopping_mall": 0,
"store": 0,
"tourist_attraction": 0,
"university": 0,
"zoo": 0]

let DEFAULT_LOVE_STATUS = [
                          false,
                          false,
                          true,
                          false,
                          false,
                          true,
                          false,
                          true,
                          false,
                          false,
                          false,
                          false,
                          true,
                          false,
                          false,
                          false,
                          false,
                          true,
                          true,
                          false]


class HealthDataController: UIViewController {
    
    var rating : [String: Int] = [:] //rating based on types

    var potentialPlaces : [String : Data] = [:]

    var loveStatus : [Bool] = DEFAULT_LOVE_STATUS
    
    var locationTypes : [String] = []
    
    var dailyDistance : Int = 0 //health
    var dailyStep : Int = 0
    var defaultGoal : Int = 0 //defaultuser
    var currentDistance : Int = 0
    var currentStep : Int = 0
    var currentToGoal : Int = 0
    var currentToDailyDistance : Int  = 0
    
    var height : String = ""
    var weight : String = ""
    
    let healthStore = HKHealthStore()
    var timer = Timer()

    var getToday = false
    var getCurrent = false
    
    @IBOutlet weak var GoalLabel: UILabel!
    
    @IBOutlet weak var DailyDistanceLabel: UILabel!
    @IBOutlet weak var CurrentAcchievementLabel: UILabel!
    @IBOutlet weak var CurrentToGoalLabel: UILabel!
    
    @IBOutlet weak var DailyStepLabel: UILabel!
    @IBOutlet weak var CurrentStepsLabel: UILabel!
    
    @IBOutlet weak var HeightLabel: UILabel!
    @IBOutlet weak var WeightLabel: UILabel!
    
    @IBOutlet weak var ChangeGoalOutlet: UIButton!
   
    @IBAction func ChangeGoalPressed(_ sender: Any) {
        let changeGoalVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(identifier: "changGoalID") as! ChangeGoalController
        self.addChild(changeGoalVC)
        changeGoalVC.view.frame = self.view.frame
        self.view.addSubview(changeGoalVC.view)
        changeGoalVC.changeGoalView.layer.masksToBounds = true
        changeGoalVC.changeGoalView.layer.cornerRadius = 8.0
        changeGoalVC.currentGoal.text = "Change Your Goal"
        changeGoalVC.enterGoal.text = String(defaultGoal)
        
        changeGoalVC.didMove(toParent: self)
    }
    
    @IBOutlet weak var Greeting: UILabel!
      
      @IBOutlet weak var GetLocationsOutlet: UIButton!

      @IBAction func GetLocationsPressed(_ sender: Any) {
          let changeGoalVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(identifier: "enterDistanceID") as! SetDistanceController
          self.addChild(changeGoalVC)
          changeGoalVC.view.frame = self.view.frame
          self.view.addSubview(changeGoalVC.view)
          changeGoalVC.enterDistanceView.layer.masksToBounds = true
          changeGoalVC.enterDistanceView.layer.cornerRadius = 8.0
          
          locationTypes = []
        
          if let x = UserDefaults.standard.object(forKey: "LOCATION_TYPE_LOVE") as? [Bool] {
                 for i in 0...LOCATION_TYPE.count-1 {
                 if(x[i] == true){
                     locationTypes.append(LOCATION_TYPE[i])
                 }
              }
          }

          changeGoalVC.locationTypes = locationTypes
        
          updateLocationRating()
          changeGoalVC.ratingTypes = rating
        
          changeGoalVC.CurrentGoal.text = "Enter Your Distance"
            if (currentToGoal >= 0){
            changeGoalVC.desiredDistance.text = String(currentToGoal)

            }
            else {
                changeGoalVC.desiredDistance.text = String(0)
        }
          changeGoalVC.CurrentGoal.layer.masksToBounds = true
          changeGoalVC.CurrentGoal.layer.cornerRadius = 8.0
          changeGoalVC.didMove(toParent: self)
      }
    
    @IBOutlet weak var ChangeLocationTypeOutlet: UIButton!
    
    @IBAction func ChangeLocationTypePressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSetLocationTypeController", sender: self)
    }
    
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setOutletLayer()
        
        updateHeathInformation()
        
        scheduledTimerWithTimeInterval()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let storedGoal = UserDefaults.standard.string(forKey: "UserGoal"),
           let goal = Int(storedGoal) {
            defaultGoal = goal
        } else if let goal = UserDefaults.standard.object(forKey: "UserGoal") as? Int {
            defaultGoal = goal
        }
    }

    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
    }

    func scheduledTimerWithTimeInterval(){
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(REFRESH_TIME),
            target: self,
            selector: #selector(updateHeathInformation),
            userInfo: nil,
            repeats: true
        )
    }
    
    func setOutletLayer(){
            GetLocationsOutlet.layer.masksToBounds = true
            GetLocationsOutlet.layer.cornerRadius = 8.0
        
            ChangeLocationTypeOutlet.layer.masksToBounds = true
            ChangeLocationTypeOutlet.layer.cornerRadius = 8.0
            
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
            
            DailyStepLabel.layer.masksToBounds = true
            DailyStepLabel.layer.cornerRadius = 8.0

            CurrentStepsLabel.layer.masksToBounds = true
            CurrentStepsLabel.layer.cornerRadius = 8.0
            
            GoalLabel.layer.masksToBounds = true
            GoalLabel.layer.cornerRadius = 8.0
            
            ChangeGoalOutlet.layer.masksToBounds = true
            ChangeGoalOutlet.layer.cornerRadius = 8.0
            
    }
    
    @objc func updateHeathInformation(){
            print("Run now")
        
           getUserDefault()
           
           getHealthInformation{
               if(self.defaultGoal > 0){
                   UserDefaults.standard.set(String(self.defaultGoal), forKey: "UserGoal")
                   self.currentToGoal = self.defaultGoal - self.currentDistance
                   self.GoalLabel.text = "Your Daily Goal\n\(String(self.defaultGoal)) m"
                   if(self.currentToGoal > 0){
                       self.CurrentToGoalLabel.text = "Keep going! You need \(String(self.currentToGoal)) m to reach your goal"
                   }
                   else {
                       self.CurrentToGoalLabel.text = "Congratulations! You reach your goal for the day."
                   }
               }
               else {
                   self.defaultGoal = self.dailyDistance
                   UserDefaults.standard.set(String(self.defaultGoal), forKey: "UserGoal")

                   self.GoalLabel.text = "Your Daily Goal\n\(String(self.dailyDistance))"
                   if(self.currentToDailyDistance > 0)
                   {
                       self.CurrentToGoalLabel.text = "Keep going! You need \(String(self.currentToDailyDistance)) m to reach your goal"
                   }
                   else {
                       self.CurrentToGoalLabel.text = "Congratulations! You reach your goal for the day."
                   }
               }
               
               self.DailyDistanceLabel.text = "Daily Distance\n\(String(self.dailyDistance)) m"

               self.CurrentAcchievementLabel.text = "Today Distance\n\(String(self.currentDistance)) m"
                         
               self.CurrentStepsLabel.text = "Today Steps\n\(String(self.currentStep))"
           }
    }
    //MARK: - Notification
    /***************************************************************/
    
    
    //MARK: - Get User Default Setting and Get Location Rating
    /***************************************************************/

    func getUserDefault(){
        
            UserDefaults.standard.set(LOCATION_TYPE, forKey: "LOCATION_TYPE")
             
             if let saved = UserDefaults.standard.object(forKey: "LOCATION_TYPE_LOVE") as? [Bool],
                saved.count == LOCATION_TYPE.count {
                 loveStatus = saved
             }
             else {
                 loveStatus = DEFAULT_LOVE_STATUS
                 UserDefaults.standard.set(DEFAULT_LOVE_STATUS, forKey: "LOCATION_TYPE_LOVE")
             }
             
             rating = DEFAULT_RATING
             
             if let x = UserDefaults.standard.object(forKey: "POTENTIAL_PLACES") as? [String : Data] {
                 potentialPlaces = x
             }
             else {
                 UserDefaults.standard.set(potentialPlaces, forKey: "POTENTIAL_PLACES")
             }
    }
    
        /***************************************************************/
        func updateLocationRating(){
            getUserDefault()

            for i in LOCATION_TYPE.indices {
                if loveStatus[i] {
                    if let currentRating = rating[LOCATION_TYPE[i]] {
                        rating[LOCATION_TYPE[i]] = currentRating + LOVE_SCORE
                    }
                }
            }
            
            for (_,data) in potentialPlaces {
                do {
                    if let decodedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? HistoryData {
                        for type in decodedData.types {
                            if let x = rating[type] {
                                rating[type] = x + TAP_SCORE
                            }
                        }
                    }
                } catch {
                    print("Couldn't read file.")
                }
            }
        }


    
    //MARK: - Get Health Data
    /***************************************************************/
    func getHealthInformation(completion : @escaping() -> Void){
        getDistanceData {
            self.currentToDailyDistance = self.dailyDistance - self.currentDistance
            completion()

            self.getUserHeight {
                self.HeightLabel.text = "Height\n\(self.height) m"
                if let height = Double(self.height), height > 0 {
                    self.dailyStep = self.getDailySteps(
                        height: height,
                        dailyDistance: self.dailyDistance
                    )
                    self.DailyStepLabel.text = "Daily Steps\n\(self.dailyStep)"
                }
            }

            self.getUserWeight {
                self.WeightLabel.text = "Weight\n\(self.weight) lbs"
            }
        }
    }

    //MARK: - Get Distance Data
    /***************************************************************/
    func getDistanceData(completion : @escaping () -> Void){
        let healthKitTypes = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .height),
            HKObjectType.quantityType(forIdentifier: .bodyMass),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        ].compactMap { $0 })

        healthStore.requestAuthorization(toShare: [], read: healthKitTypes) { granted, error in
            guard granted else {
                if let error = error {
                    print("HealthKit authorization error: \(error)")
                }
                DispatchQueue.main.async {
                    completion()
                }
                return
            }

            let group = DispatchGroup()

            group.enter()
            self.getTodaySteps { result in
                DispatchQueue.main.async {
                    self.currentStep = Int(result)
                    group.leave()
                }
            }

            group.enter()
            self.getTodayDistance { result in
                DispatchQueue.main.async {
                    self.currentDistance = Int(round(result))
                    group.leave()
                }
            }

            group.enter()
            self.getDailyDistance { result in
                DispatchQueue.main.async {
                    self.dailyDistance = Int(round(result))
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    
    func getDailyDistance(completion: @escaping (Double) -> Void){
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(0)
            return
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, statistics, error in
            if let error = error {
                print("Daily distance query error: \(error)")
                completion(0)
                return
            }

            let total = statistics?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
            completion(total / 365.0)
        }

        healthStore.execute(query)
    }

    func getTodayDistance(completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(0)
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, statistics, error in
            if let error = error {
                print("Today distance query error: \(error)")
            }
            completion(statistics?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0)
        }

        healthStore.execute(query)
    }

    
    //MARK: - Get Step Data
    /***************************************************************/
    func getDailySteps(height : Double, dailyDistance : Int) -> Int{
        var i = Double(5280 * 12 * Double(dailyDistance) * 0.000621371)
        i = i / (height * 39.37 * 0.413)
        
        return Int(i)
    }
    
    func getTodaySteps(completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, statistics, error in
            if let error = error {
                print("Today steps query error: \(error)")
            }
            completion(statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
        }

        healthStore.execute(query)
    }
    
   
    //MARK: - Get Height Data
    /***************************************************************/
    func getUserHeight(completion: @escaping () -> Void) {
        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height) else {
            completion()
            return
        }

        healthStore.aapl_mostRecentQuantitySampleOfType(heightType, predicate: nil) {
            mostRecentQuantity, error in

            if let error = error {
                print("Height query error: \(error)")
            }

            guard let quantity = mostRecentQuantity else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }

            let meters = quantity.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async {
                self.height = String(format: "%.2f", meters)
                completion()
            }
        }
    }

    func getUserWeight(completion: @escaping () -> Void) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion()
            return
        }

        healthStore.aapl_mostRecentQuantitySampleOfType(weightType, predicate: nil) {
            mostRecentQuantity, error in

            if let error = error {
                print("Weight query error: \(error)")
            }

            guard let quantity = mostRecentQuantity else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }

            let pounds = quantity.doubleValue(for: HKUnit.pound())
            DispatchQueue.main.async {
                self.weight = String(format: "%.1f", pounds)
                completion()
            }
        }
    }
    
    
    //MARK: - Segue
    /***************************************************************/

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "goToHealthDataController"{
                   let destinationVC = segue.destination as! HealthDataController
                   
                   destinationVC.defaultGoal = defaultGoal
               }
    }

    @IBAction func unwindToHealthDataControllerMap(_sender : UIStoryboardSegue){
    }

    @IBAction func unwindToHealthDataControllerUpdate(_sender : UIStoryboardSegue){
        
        if _sender.source is ChangeGoalController{
            if let senderVC = _sender.source as? ChangeGoalController{
                if let goalText = senderVC.enterGoal.text,
                   let goal = Int(goalText),
                   goal > 0 {
                    UserDefaults.standard.set(goalText, forKey: "UserGoal")
                    defaultGoal = goal
                    currentToGoal = defaultGoal - currentDistance
                    GoalLabel.text = "Your Daily Goal\n\(goal) m"
                     if(currentToGoal > 0){
                        CurrentToGoalLabel.text = "Keep going! You need \(String(currentToGoal)) m to reach your goal"
                    }
                    else {
                        CurrentToGoalLabel.text = "Congratulations! You reach your goal for the day."
                    }
                }
                
                senderVC.view.removeFromSuperview()
            }
        }
    }
    
    @IBAction func unwindToHealthDataControllerCancel(_sender : UIStoryboardSegue){
           
           if _sender.source is ChangeGoalController{
               if let senderVC = _sender.source as? ChangeGoalController{
                  senderVC.view.removeFromSuperview()
               }
           }
       }
    
    @IBAction func unwindToHealthDataControllerDefault(_sender : UIStoryboardSegue){
              
              if _sender.source is ChangeGoalController{
                   if let senderVC = _sender.source as? ChangeGoalController{
                       UserDefaults.standard.set(String(dailyDistance), forKey: "UserGoal")
                       defaultGoal = dailyDistance
                       currentToGoal = defaultGoal - currentDistance
                       GoalLabel.text = "Your Daily Goal\n\(String(defaultGoal)) m"
                        if(currentToGoal > 0){
                           CurrentToGoalLabel.text = "Keep going! You need \(String(currentToGoal)) m to reach your goal"
                       }
                       else {
                           CurrentToGoalLabel.text = "Congratulations! You reach your goal for the day."
                       }
                       
                       senderVC.view.removeFromSuperview()
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
            
            if let completion = completion {
                let quantitySample = results?.first as? HKQuantitySample
                completion(quantitySample?.quantity, error)
            }
        }
        
        self.execute(query)
    }
    
}

