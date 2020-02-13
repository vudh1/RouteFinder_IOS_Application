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

class ViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var Button: UIButton!
    
    let locationManager = CLLocationManager()
    let nearbyLocationDataModel = NearbyLocationDataModel()
    let locationDirectionDataModel = LocationDirectionDataModel()
    
    
    let NEARBYSEARCH_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let DIRECTION_API_URL = "https://maps.googleapis.com/maps/api/directions/json?"
    let GOOGLE_APP_ID = "AIzaSyDS8N3_J0XJ4OwKElqCRwAqW1-AYB41glA"
    let MAX_RADIUS = "10000"
    let TRAVEL_MODE = "walking"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation() //asynchronous Method - work in background
    }
    //MARK: - Networking
    /***************************************************************/
    func getNearbyLocationData(nearbyUrl : String,directionUrl : String, parameters : [String: String]){
        Alamofire.request(nearbyUrl, method : .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Got Nearby Location Data")
            
                let nearbyLocationJSON : JSON = JSON(response.result.value!)
                
                self.updateNearbyLocationData(json: nearbyLocationJSON)
                self.getNearbyDirectionData(url: directionUrl, originParameters: parameters, nearbyLocationDataModel : self.nearbyLocationDataModel)

            }
            else {
                print("Error \(response.result.error)")
               // self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    func getNearbyDirectionData(url : String, originParameters : [String: String], nearbyLocationDataModel : NearbyLocationDataModel){
        for destinationInfo in nearbyLocationDataModel.nearbyLocationDataList{
            let params : [String : String] = ["origin" : "\(String(originParameters["location"]!))","destination" : "\(destinationInfo.latitude),\(destinationInfo.longitude)","mode" : TRAVEL_MODE,"key" : GOOGLE_APP_ID]
            
            Alamofire.request(url, method : .get, parameters: params).responseJSON{
                       response in
                       if response.result.isSuccess{
                           print("Success! Got Nearby Direction Location Data")
                       
                           let nearbyLocationDirectionJSON : JSON = JSON(response.result.value!)
                           
                        self.updateNearbyLocationDirectionData(json: nearbyLocationDirectionJSON,destinationInfo : destinationInfo)
                       
                           print(nearbyLocationDirectionJSON)
                       }
                       else {
                           print("Error \(response.result.error)")
                          // self.cityLabel.text = "Connection Issues"
                       }
                   }
        }
   }
    
     //MARK: - JSON Parsing
     /***************************************************************/
     //Write the updateNearbyLocationData method here:
    func updateNearbyLocationData(json : JSON){

        let tempResults = json["results"].array
        
        for tempResult in tempResults!{
            let tempName = tempResult["name"].stringValue
            let tempVicinity = tempResult["vicinity"].stringValue
            let tempLatitude = tempResult["geometry"]["location"]["lat"].doubleValue
            let tempLongitude = tempResult["geometry"]["location"]["lng"].doubleValue
            let tempPlaceID = tempResult["place_ID"].stringValue
            
            nearbyLocationDataModel.nearbyLocationDataList.append(NearbyLocation(name :  tempName,vicinity : tempVicinity, latitude : tempLatitude, longitude : tempLongitude , placeID : tempPlaceID))
        }
        
    }
    
    
    func updateNearbyLocationDirectionData(json : JSON,destinationInfo : NearbyLocation){
        if let tempDistance = json["routes"][0]["legs"][0]["distance"]["value"].int {
            let tempDuration = json["routes"][0]["legs"][0]["duration"]["value"].intValue
        
            locationDirectionDataModel.locationDirectionDataList.append(nearbyLocationDirection(name : destinationInfo.name, latitude : destinationInfo.latitude, longitude : destinationInfo.longitude, distance : tempDistance, duration : tempDuration))
        }
    }

    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation() // stop checking location for battery saving
            locationManager.delegate = nil // stop printing the JSON output right after location is found

            print("Current latitude = \(location.coordinate.latitude)")
            print("Current longitude = \(location.coordinate.longitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let originParams : [String : String] = ["location": "\(latitude),\(longitude)" , "radius" : MAX_RADIUS ,"type" : "park", "key" : GOOGLE_APP_ID]
            
            getNearbyLocationData(nearbyUrl: NEARBYSEARCH_API_URL,directionUrl : DIRECTION_API_URL, parameters: originParams)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
        //cityLabel.text = "Location Unavailable"
    }

}

