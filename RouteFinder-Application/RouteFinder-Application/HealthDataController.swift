//
//  HealthDataControllerViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/4/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import HealthKit

let LOVE_SCORE = 5
let TAP_SCORE = 1
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
    
    var rating : [String: Int] = [:]
    
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
          changeGoalVC.desiredDistance.text = String(currentToGoal)
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
        if let x = UserDefaults.standard.object(forKey: "UserGoal") as? String {
            defaultGoal = Int(x)!
        }
    }

    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
    }

    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(REFRESH_TIME), target: self, selector: Selector(("updateHeathInformation")), userInfo: nil, repeats: true)
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
    
    
    //MARK: - Get User Default Setting and Get Location Rating
    /***************************************************************/

    func getUserDefault(){
        
            UserDefaults.standard.set(LOCATION_TYPE, forKey: "LOCATION_TYPE")
             
             if let x = UserDefaults.standard.object(forKey: "LOCATION_TYPE_LOVE") as? [Bool] {
                 loveStatus = x
             }
             else {
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

            for i in 0...LOCATION_TYPE.count - 1{
                if(loveStatus[i]){
                    if let x = rating[LOCATION_TYPE[i]] {
                        rating[LOCATION_TYPE[i]] = x + LOVE_SCORE
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
                        }                    }
                } catch {
                    print("Couldn't read file.")
                }
            }
        }


    
    //MARK: - Get Health Data
    /***************************************************************/
    func getHealthInformation(completion : @escaping() -> Void){
        getDistanceData {
                   if (self.getToday && self.getCurrent){
                       self.currentToDailyDistance = self.dailyDistance - self.currentDistance
                    
                    self.getToday = false
                    self.getCurrent = false
                    
                    completion()
                    
                    self.getUserHeight{
                        self.HeightLabel.text = "Height\n\(self.height) m"
                        self.dailyStep = self.getDailySteps(height: Double(self.height)!, dailyDistance: self.dailyDistance)
                        self.DailyStepLabel.text = "Daily Steps\n\(String(self.dailyStep))"                    }
                    
                    self.getUserWeight{
                        self.WeightLabel.text = "Weight\n\(self.weight) lbs"
                    }
                    
                   }
            
                    completion()
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
            self.getTodaySteps { (result) in
                DispatchQueue.main.async {
                    self.currentStep = Int(result)
                    completion()
                    }
                }
            }
            
            self.getTodayDistance { (result) in
                DispatchQueue.main.async {
                    self.currentDistance = Int(round(result))
                    self.getToday = true
                    completion()
                }
            }
                        
            self.getDailyDistance{ (result) in
                DispatchQueue.main.async {
                    self.dailyDistance = Int(round(result))
                    self.getCurrent = true
                    completion()
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
    func getDailySteps(height : Double, dailyDistance : Int) -> Int{
        var i = Double(5280 * 12 * Double(dailyDistance) * 0.000621371)
        i = i / (height * 39.37 * 0.413)
        
        return Int(i)
    }
    
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
    func getUserHeight(completion: @escaping () -> Void) {
        // Fetch user's default height unit in inches.
        let lengthFormatter = LengthFormatter()
        lengthFormatter.unitStyle = Formatter.UnitStyle.long
        
        let heightFormatterUnit = LengthFormatter.Unit.inch
        let heightUnitString = lengthFormatter.unitString(fromValue: 10, unit: heightFormatterUnit)
        let localizedHeightUnitDescriptionFormat = NSLocalizedString("Height (%@)", comment: "")
        
        self.height = String(format: localizedHeightUnitDescriptionFormat, heightUnitString)
        
        let heightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        
        // Query to get the user's latest height, if it exists.
        self.healthStore.aapl_mostRecentQuantitySampleOfType(heightType, predicate: nil) {mostRecentQuantity, error in
            if mostRecentQuantity == nil {
                NSLog("Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.")
                
                DispatchQueue.main.async {}
            } else {
                // Determine the height in the required unit.
                let heightUnit = HKUnit.inch()
                let usersHeight = mostRecentQuantity!.doubleValue(for: heightUnit)
                
                // Update the user interface.
                DispatchQueue.main.async {
                    let h : Double = Double(Int(NumberFormatter.localizedString(from: usersHeight as NSNumber, number: NumberFormatter.Style.none))!)
                    self.height = String(round(Double(h * 2.54))/100.00)
                    completion()
                }
            }
        }
    }
    
    //MARK: - Get Weight Data
    /***************************************************************/
    func getUserWeight(completion: @escaping () -> Void) {
        // Fetch the user's default weight unit in pounds.
        let massFormatter = MassFormatter()
        massFormatter.unitStyle = .long
        
        let weightFormatterUnit = MassFormatter.Unit.pound
        let weightUnitString = massFormatter.unitString(fromValue: 10, unit: weightFormatterUnit)
        let localizedWeightUnitDescriptionFormat = NSLocalizedString("Weight (%@)", comment: "")
        
        self.weight = String(format:localizedWeightUnitDescriptionFormat, weightUnitString)
        
        // Query to get the user's latest weight, if it exists.
        let weightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        
        self.healthStore.aapl_mostRecentQuantitySampleOfType(weightType, predicate: nil) {mostRecentQuantity, error in
            if mostRecentQuantity == nil {
                NSLog("Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.")
                
                DispatchQueue.main.async {}
            } else {
                // Determine the weight in the required unit.
                let weightUnit = HKUnit.pound()
                let usersWeight = mostRecentQuantity!.doubleValue(for: weightUnit)
                
                // Update the user interface.
                DispatchQueue.main.async {
                    self.weight = NumberFormatter.localizedString(from: usersWeight as NSNumber, number: .none)
                    completion()
                }
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
                if senderVC.enterGoal.text! != ""{
                    UserDefaults.standard.set(senderVC.enterGoal.text!, forKey: "UserGoal")
                    defaultGoal = Int(senderVC.enterGoal.text!)!
                    currentToGoal = defaultGoal - currentDistance
                    GoalLabel.text = "Your Daily Goal\n\(String(senderVC.enterGoal.text!)) m"
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
                       UserDefaults.standard.set(dailyDistance, forKey: "UserGoal")
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

