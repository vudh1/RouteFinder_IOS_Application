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
    let SEARCH_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let DIRECTION_API_URL = "https://maps.googleapis.com/maps/api/directions/json?"
    let GOOGLE_APP_ID = "AIzaSyDS8N3_J0XJ4OwKElqCRwAqW1-AYB41glA"
    
    //local variables: all distance units are meters
    var MAX_RADIUS = 10000
    let MAX_DIFF_FROM_DISTANCE = 500
    let MIN_DISTANCE = 1
    let TRAVEL_MODE = "walking"
    let MAX_CELL = 15

    let LOCATION_TYPE = ["library","amusement_park","aquarium","art_gallery","bakery","bar","book_store","cafe","grocery_or_supermarket","gym","movie_theater","museum","park","restaurant","shopping_mall","tourist_attraction","zoo"]//add more location_type
    
    var travelGoalDistance = 0
    var getLocationDataCount = 0
    var updateLocationDataCount = 0
    var updateLocationDirectionDataCount = 0
    var desiredDistanceFromHealthController : String?
    var sortingOption : Int = 0
    var mapDestinationLatitude : Double = 0
    var mapDestinationLongitude : Double = 0
    var mapLocationName : String = ""
    
    //Storyboard Elements
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sortingSegmentOutlet: UISegmentedControl!
    @IBAction func sortingChange(_ sender: Any) {
        switch sortingSegmentOutlet.selectedSegmentIndex{
        case 0:
            sortingOption = 0
            nearbyLocationUpdate()
            break
        case 1:
            sortingOption = 1
            nearbyLocationUpdate()
            break
        case 2:
            sortingOption = 2
            nearbyLocationUpdate()
            break
        default:
            break
        }
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
                        
            for i in 0...LOCATION_TYPE.count-1{
                let originParams : [String : String] = ["location": "\(latitude),\(longitude)" , "radius" : String(MAX_RADIUS) ,"type" : LOCATION_TYPE[i], "key" : GOOGLE_APP_ID]
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
        print("DoneLocationManager")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK : - function Call Location
      func nearbyLocationUpdate(){
          updateLocationDataCount = 0
          getLocationDataCount = 0
          updateLocationDirectionDataCount = 0
          
          if Int(desiredDistanceFromHealthController!)! > 0{
              travelGoalDistance = Int(desiredDistanceFromHealthController!)!
          }
          else {
              travelGoalDistance = MIN_DISTANCE
          }
             
          MAX_RADIUS = travelGoalDistance + MAX_DIFF_FROM_DISTANCE
          
          locationDataModel.locationDataList.removeAll()
          locationDirectionModel.locationDirectionList.removeAll()
          
          locationManager.delegate = self
          locationManager.desiredAccuracy = kCLLocationAccuracyBest
          locationManager.requestWhenInUseAuthorization()
          locationManager.startUpdatingLocation()
      }

    //MARK: - Networking
    /***************************************************************/
    func getLocationData(Url : String, parameters : [String: String], completion : @escaping ()->Void){
        print("GetLocationData")
        
        AF.request(Url, method : .get, parameters: parameters).responseJSON{ response in
            switch response.result{
            case .success(let value):
                let locationJSON = JSON(value)
                self.updateLocationData(json: locationJSON){
                    self.updateLocationDataCount+=1
                    self.getLocationDataCount+=1
                    completion()
                }
            case .failure(let error):
                print("Error \(error)")
                completion()
            }
        }
        
        print("DoneGetLocationData")
    }

    func getDirectionData(url : String, originParameters : [String: String], LocationDataModel : LocationDataModel, completion : () -> Void){
        print("GetDirectionData")
                
        for (_,destinationInfo) in locationDataModel.locationDataList{
            let params : [String : String] = ["origin" : "\(String(originParameters["location"]!))","destination" : "\(destinationInfo.latitude),\(destinationInfo.longitude)","mode" : TRAVEL_MODE,"key" : GOOGLE_APP_ID]

            AF.request(url, method : .get, parameters: params).responseJSON{ response in
                switch response.result{
                case .success(let value):
                     let locationDirectionJSON = JSON(value)
                                        
                     self.updateLocationDirectionData(json: locationDirectionJSON, destinationInfo: destinationInfo){
                        self.updateLocationDirectionDataCount+=1
                        print("updateLocationDirectionDataCount: \(self.updateLocationDirectionDataCount)")
                        print("self.locationDataModel.locationDataList.count: \(self.locationDataModel.locationDataList.count)")
                        if(self.updateLocationDirectionDataCount == self.locationDataModel.locationDataList.count){
                            print("Sorting LocationDirectionList")
                            self.locationDirectionModel.sortLocationDirectionList(desiredDistance: self.travelGoalDistance, sortingOption: self.sortingOption)
                            self.tableView.reloadData()
                        }
                    }
                    
                case .failure(let error):
                    print("Error \(error)")
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
            
            locationDataModel.locationDataList[tempName] = Location(name :  tempName,vicinity : tempVicinity, latitude : tempLatitude, longitude : tempLongitude , placeID : tempPlaceID)
        }
        
        print("DoneUpdateLocationData")
        
        completion()
    }
    
    func updateLocationDirectionData(json : JSON,destinationInfo : Location, completion : () -> Void ){
        print("UpdateLocationDirectionData")
        if let tempDistance = json["routes"][0]["legs"][0]["distance"]["value"].int {
            let tempDuration = json["routes"][0]["legs"][0]["duration"]["value"].intValue

            locationDirectionModel.locationDirectionList.append(LocationDirection(name : destinationInfo.name, latitude : destinationInfo.latitude, longitude : destinationInfo.longitude, distance : tempDistance, duration : tempDuration))
        }
        print("DoneUpdateLocationDirectionData")
        
        completion()
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
        
        cell.setLocationCellValues(infoParameters: infoParameters, coordinateParameters: coordinateParameters)
        
        cell.delegate = self

        return cell
    }
    
    //MARK :- GoToMapController
    /***************************************************************/

    func didTapAppleMap(locationLatitude : Double,locationLongitude : Double, locationName : String ){
        mapDestinationLatitude = locationLatitude
        mapDestinationLongitude = locationLongitude
        mapLocationName = locationName
        
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
    
    //MARK: - Unwind Segue
    /***************************************************************/

    @IBAction func unwindToNavigationController(_sender : UIStoryboardSegue){}

}


