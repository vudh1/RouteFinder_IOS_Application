//
//  ViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/12/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class NavigationController: UIViewController,CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate,LocationCellDelegate {
    
    //model variables
    let locationManager = CLLocationManager()
    let locationDataModel = LocationDataModel()
    let locationDirectionModel = LocationDirectionModel()
    
    //API information
    var SEARCH_API_URL = ""
    var DIRECTION_API_URL = ""
    var GOOGLE_API_ID = ""
    
    //local variables: all distance units are meters
    var LOCATION_TYPE  : [String] = []
    var RATING : [String : Int] = [:]
    
    var max_radius = MAX_RADIUS
    
    var travelGoalDistance = 0
    var getLocationDataCount = 0
    var updateLocationDataCount = 0
    var updateLocationDirectionDataCount = 0
    var desiredDistanceFromHealthController : String?
    var sortingOption : Int = 1
    var mapDestinationLatitude : Double = 0
    var mapDestinationLongitude : Double = 0
    var mapLocationName : String = ""
    
    //Storyboard Elements
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sortingSegmentOutlet: UISegmentedControl!
    @IBAction func sortingChange(_ sender: Any) {
        locationDirectionModel.sortLocationDirectionList(desiredDistance: self.travelGoalDistance, sortingOption:          sortingSegmentOutlet.selectedSegmentIndex)
        tableView.reloadData()
    }
    
    @IBOutlet weak var backOutlet: UIButton!
    
    @IBOutlet weak var refreshOutlet: UIButton!
    
    @IBAction func refreshPressed(_ sender: Any) {
        nearbyLocationUpdate()
    }
    
    /***************************************************************/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backOutlet.layer.masksToBounds = true
        backOutlet.layer.cornerRadius = 8.0
        
        refreshOutlet.layer.masksToBounds = true
        refreshOutlet.layer.cornerRadius = 8.0
        sortingSegmentOutlet.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Black",size : 17)!], for: .normal)
        
        nearbyLocationUpdate()
    }


    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("LocationManager")
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0{
            self.locationManager.stopUpdatingLocation() // stop checking location for battery saving
            self.locationManager.delegate = nil // stop printing the JSON output right after location is found

            print("Current latitude = \(location.coordinate.latitude)")
            print("Current longitude = \(location.coordinate.longitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            if LOCATION_TYPE.count > 0 {
                for i in 0...LOCATION_TYPE.count-1{
                    let originParams : [String : String] = ["location": "\(latitude),\(longitude)" , "radius" : String(max_radius) ,"type" : LOCATION_TYPE[i], "key" : GOOGLE_API_ID]
                    getLocationData(Url: SEARCH_API_URL, parameters: originParams){
                        //only getDirection after searching nearbyLocation of all types
                        print("self.updateLocationDataCount : \(self.updateLocationDataCount)")
                        print("self.LOCATION_TYPE.count: \(self.LOCATION_TYPE.count)")
                        if(self.getLocationDataCount == self.LOCATION_TYPE.count && self.updateLocationDataCount == self.LOCATION_TYPE.count){
                            print("getDirectionData After Loop done")
                            self.getDirectionData(url: self.DIRECTION_API_URL, originParameters: originParams, LocationDataModel : self.locationDataModel){
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }

        }
        print("DoneLocationManager")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK : - function Call Location
    /***************************************************************/

      func nearbyLocationUpdate(){
        if setKeyValues() == true {
            print("Important Keys are Read!!!")
            updateLocationDataCount = 0
                     getLocationDataCount = 0
                     updateLocationDirectionDataCount = 0
                     
                     if Int(desiredDistanceFromHealthController!)! > 0{
                         travelGoalDistance = Int(desiredDistanceFromHealthController!)!
                     }
                     else {
                         travelGoalDistance = MIN_DISTANCE
                     }
                        
                     max_radius = travelGoalDistance + MAX_DIFF_FROM_DISTANCE
                     
                     locationDataModel.locationDataList.removeAll()
                     locationDirectionModel.locationDirectionList.removeAll()
                     
                     locationManager.delegate = self
                     locationManager.desiredAccuracy = kCLLocationAccuracyBest
                     locationManager.requestWhenInUseAuthorization()
                     locationManager.startUpdatingLocation()
        }
        else {
            print("Important Keys are not Read!!!")
        }
      }
    
    
       func setKeyValues() -> Bool{
           var keys: NSDictionary?
           
           if let pathToKeys = Bundle.main.path(forResource: "Keys", ofType: "plist") {
               keys = NSDictionary(contentsOfFile: pathToKeys)
           }
           
           if let dict = keys {
                SEARCH_API_URL = dict["placesAPI"] as! String
                DIRECTION_API_URL = dict["directionsAPI"]  as! String
                GOOGLE_API_ID = dict["googleAPIKey"]  as! String
               
               return true
           }
           
           return false
       }

    //MARK: - Networking
    /***************************************************************/
    func getLocationData(Url : String, parameters : [String: String], completion : @escaping ()->Void){
        print("GetLocationData")
        
        self.getLocationDataCount+=1

        AF.request(Url, method : .get, parameters: parameters).responseJSON{ response in
            switch response.result{
            case .success(let value):
                let locationJSON = JSON(value)
                self.updateLocationData(json: locationJSON){
                    self.updateLocationDataCount+=1

                    completion()
                }
            case .failure(let error):
                print("Error \(error)")
                completion()
            }
        }
        
        print("DoneGetLocationData")
    }

    func getDirectionData(url : String, originParameters : [String: String], LocationDataModel : LocationDataModel, completion : @escaping () -> Void){
        print("GetDirectionData")
                
        for (_,destinationInfo) in locationDataModel.locationDataList{
            let params : [String : String] = ["origin" : "\(String(originParameters["location"]!))","destination" : "\(destinationInfo.latitude),\(destinationInfo.longitude)","mode" : TRAVEL_MODE,"key" : GOOGLE_API_ID]

            AF.request(url, method : .get, parameters: params).responseJSON{ response in
                switch response.result{
                case .success(let value):
                     let locationDirectionJSON = JSON(value)
                                        
                     self.updateLocationDirectionData(json: locationDirectionJSON, destinationInfo: destinationInfo){
                        self.updateLocationDirectionDataCount+=1
                        print("updateLocationDirectionDataCount: \(self.updateLocationDirectionDataCount)")
                        print("self.locationDataModel.locationDataList.count: \(self.locationDataModel.locationDataList.count)")
                        if(self.updateLocationDirectionDataCount == self.locationDataModel.locationDataList.count && self.updateLocationDirectionDataCount <= MAX_DIRECTION_SEARCH){
                            
                            print("Sorting LocationDirectionList")
                            self.locationDirectionModel.sortLocationDirectionList(desiredDistance: self.travelGoalDistance, sortingOption: self.sortingOption)
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                    completion()
                    
                case .failure(let error):
                    print("Error \(error)")
                    
                    completion()

                }
            }
        }
        
        print("DoneGetDirectionData")
   }
    
    
     //MARK: - JSON Parsing
     /***************************************************************/

    func updateLocationData(json : JSON, completion : () -> Void){
        print("UpdateLocationData")
        
        let tempResults = json["results"].array
        
        for tempResult in tempResults!{
            let tempName = tempResult["name"].stringValue
            let tempVicinity = tempResult["vicinity"].stringValue
            let tempLatitude = tempResult["geometry"]["location"]["lat"].doubleValue
            let tempLongitude = tempResult["geometry"]["location"]["lng"].doubleValue
            let tempPlaceID = tempResult["place_ID"].stringValue
            let tempTypes = tempResult["types"].arrayObject as! [String]
            let tempRating = getLocationRating(types: tempTypes)
            locationDataModel.locationDataList[tempName] = Location(name :  tempName,vicinity : tempVicinity, latitude : tempLatitude, longitude : tempLongitude , placeID : tempPlaceID, types: tempTypes, rating: tempRating)
        }
        
        print("DoneUpdateLocationData")
        
        completion()
    }
    
    func updateLocationDirectionData(json : JSON,destinationInfo : Location, completion : () -> Void ){
        print("UpdateLocationDirectionData")
        if let tempDistance = json["routes"][0]["legs"][0]["distance"]["value"].int {
            let tempDuration = json["routes"][0]["legs"][0]["duration"]["value"].intValue
            locationDirectionModel.locationDirectionList.append(LocationDirection(name : destinationInfo.name, latitude : destinationInfo.latitude, longitude : destinationInfo.longitude, distance : tempDistance, duration : tempDuration, types: destinationInfo.types, rating: destinationInfo.rating))
        }
        print("DoneUpdateLocationDirectionData")
        
        completion()
    }

    //MARK: - Get Location Rating
    /***************************************************************/
    func getLocationRating(types : [String]) -> Int {
        var result = 0
        
        for type in types{
            if let x = RATING[type]{
                result += x
            }
        }
        
        return result
    }
    
    //MARK: - TableView
    /***************************************************************/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Reload Table")
        
        if (locationDirectionModel.locationDirectionList.count<=MAX_CELL){
            return locationDirectionModel.locationDirectionList.count
        }
        else {
            return MAX_CELL
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        locationManager.startUpdatingLocation()

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LocationCell
       
        let locationName = locationDirectionModel.locationDirectionList[indexPath.row].name
        
        let distanceInKilometers = "\(String(format :"%.1f",Double(locationDirectionModel.locationDirectionList[indexPath.row].distance)/1000.000)) km"

        let durationInMinutes = "\(String(locationDirectionModel.locationDirectionList[indexPath.row].duration/60)) mins"
        
        let locationLatitude = locationDirectionModel.locationDirectionList[indexPath.row].latitude
    
        let locationLongitude = locationDirectionModel.locationDirectionList[indexPath.row].longitude

        let infoParameters : [String : String] = [ "locationName" : locationName, "locationDistance" : distanceInKilometers, "locationDuration" : durationInMinutes]
        
        let coordinateParameters : [String : Double] = [ "locationLatitude" : locationLatitude, "locationLongitude" : locationLongitude]
        
        let infoTypes = locationDirectionModel.locationDirectionList[indexPath.row].types
        
        cell.setLocationCellValues(infoParameters: infoParameters, coordinateParameters: coordinateParameters,infoTypes: infoTypes)
        
        cell.delegate = self

        return cell
    }
    
    //MARK :- Segue
    /***************************************************************/

    func didTapAppleMap(locationLatitude : Double,locationLongitude : Double, locationName : String, types : [String]){
        mapDestinationLatitude = locationLatitude
        mapDestinationLongitude = locationLongitude
        mapLocationName = locationName
        
        let currentTime = Date().timeIntervalSinceReferenceDate
        let data = HistoryData(locationName: locationName,types: types,time: currentTime)
        
         do {
             let encodedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
             
             if var x = UserDefaults.standard.object(forKey: "POTENTIAL_PLACES") as? [String:Data]{
                x[locationName] = encodedData
                UserDefaults.standard.set(x, forKey: "POTENTIAL_PLACES")
            }
            else {
                var y : [String : Data] = [:]
                y[locationName] = encodedData
                UserDefaults.standard.set(y, forKey: "POTENTIAL_PLACES")
            }
             
         } catch {
             print("Could not print Data")
         }
              
        performSegue(withIdentifier: "goToMapController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapController"{
            let destinationVC = segue.destination as! MapController
            
            destinationVC.destLatitude = mapDestinationLatitude
            destinationVC.destLongitude = mapDestinationLongitude
            destinationVC.destName = mapLocationName
        }
    }
    
  @IBAction func unwindToNavigationController(_sender : UIStoryboardSegue){}

}


