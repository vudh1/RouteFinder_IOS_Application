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
    
    let GOOGLE_MAP_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    
    let GOOGLE_APP_ID = "AIzaSyDS8N3_J0XJ4OwKElqCRwAqW1-AYB41glA"
    let MAX_RADIUS = "10000"
    
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
    
    //Write the getWeatherData method here:
    func getNearbyLocationData(url : String, parameters : [String: String]){
        Alamofire.request(url, method : .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Got the nearby Location data")
            
                let nearbyLocationJSON : JSON = JSON(response.result.value!)
                
                self.updateNearbyLocationData(json: nearbyLocationJSON)
            
            }
            else {
                print("Error \(response.result.error)")
               // self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
     //MARK: - JSON Parsing
     /***************************************************************/
    
     
     //Write the updateWeatherData method here:
     func updateNearbyLocationData(json : JSON){
         

        let tempResults = json["results"].array
        
        for tempResult in tempResults!{
            let tempName = tempResult["name"].stringValue
            let tempVicinity = tempResult["vicinity"].stringValue
            let tempLatitude = tempResult["geometry"]["location"]["lat"].doubleValue
            let tempLongitude = tempResult["geometry"]["location"]["lng"].doubleValue
            let tempPlaceID = tempResult["place_ID"].stringValue
            
            nearbyLocationDataModel.nearbyLocationData.append(NearbyLocation(name :  tempName,vicinity : tempVicinity, latitude : tempLatitude, longitude : tempLongitude , placeID : tempPlaceID))
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
            
            let params : [String : String] = ["location": "\(latitude),\(longitude)" , "radius" : MAX_RADIUS ,"type" : "park", "key" : GOOGLE_APP_ID]
            
            getNearbyLocationData(url: GOOGLE_MAP_API_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
        //cityLabel.text = "Location Unavailable"
    }

}

