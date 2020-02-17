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

class ViewController: UIViewController,CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate{
    
    //model variables
    let locationManager = CLLocationManager()
    let locationDataModel = LocationDataModel()
    let locationDirectionModel = LocationDirectionModel()
    
    //API information
    let SEARCH_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let DIRECTION_API_URL = "https://maps.googleapis.com/maps/api/directions/json?"
    let GOOGLE_APP_ID = "AIzaSyDS8N3_J0XJ4OwKElqCRwAqW1-AYB41glA"
    
    //local variables
    let MAX_RADIUS = "10000"
    let TRAVEL_MODE = "walking"
    let LOCATION_TYPE = "park"
    var radius : String = "10000"

    
    //Storyboard Elements
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var desiredRadius: UITextField!
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        print("Button Press: \(desiredRadius.text!)")
        locationDataModel.locationDataList.removeAll()
        locationDirectionModel.locationDirectionList.removeAll()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        tableView.reloadData()
        
        print("Done Pressed")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        desiredRadius.delegate = self
        desiredRadius.text = MAX_RADIUS
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation() //asynchronous Method - work in background
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager")
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0{
            self.locationManager.stopUpdatingLocation() // stop checking location for battery saving
            self.locationManager.delegate = nil // stop printing the JSON output right after location is found

            print("Current latitude = \(location.coordinate.latitude)")
            print("Current longitude = \(location.coordinate.longitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            radius = desiredRadius.text!
            
            let originParams : [String : String] = ["location": "\(latitude),\(longitude)" , "radius" : radius ,"type" : LOCATION_TYPE, "key" : GOOGLE_APP_ID]
            
            getLocationData(Url: SEARCH_API_URL,directionUrl : DIRECTION_API_URL, parameters: originParams)
        }
        print("doneLocationManager")
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
        //cityLabel.text = "Location Unavailable"
    }

    //MARK: - Networking
    /***************************************************************/
    func getLocationData(Url : String,directionUrl : String, parameters : [String: String]){
        print("getLocationData")
        
        AF.request(Url, method : .get, parameters: parameters).responseJSON{ response in
            switch response.result{
            case .success(let value):
                let locationJSON = JSON(value)
                self.updateLocationData(json: locationJSON)
                self.getDirectionData(url: directionUrl, originParameters: parameters, LocationDataModel : self.locationDataModel)
            case .failure(let error):
                print("Error \(error)")

            }
        }
        print("donegetLocationData")
    }
    
//    getLocationData { () -> () in
//    }
    
    func getDirectionData(url : String, originParameters : [String: String], LocationDataModel : LocationDataModel){
        print("getDirectionData")
        for destinationInfo in locationDataModel.locationDataList{
            let params : [String : String] = ["origin" : "\(String(originParameters["location"]!))","destination" : "\(destinationInfo.latitude),\(destinationInfo.longitude)","mode" : TRAVEL_MODE,"key" : GOOGLE_APP_ID]
            
            AF.request(url, method : .get, parameters: params).responseJSON{ response in
                switch response.result{
                case .success(let value):
                     let locationDirectionJSON = JSON(value)
                     self.updateLocationDirectionData(json: locationDirectionJSON, destinationInfo: destinationInfo)
                case .failure(let error):
                    print("Error \(error)")

                }
            }
         

        }
            
        print("donegetDirectionData")
   }
    
    
     //MARK: - JSON Parsing
     /***************************************************************/
     //Write the updateLocationData method here:
    func updateLocationData(json : JSON){
        print("updateLocationData")
        
        
        let tempResults = json["results"].array
        
        for tempResult in tempResults!{
            let tempName = tempResult["name"].stringValue
            let tempVicinity = tempResult["vicinity"].stringValue
            let tempLatitude = tempResult["geometry"]["location"]["lat"].doubleValue
            let tempLongitude = tempResult["geometry"]["location"]["lng"].doubleValue
            let tempPlaceID = tempResult["place_ID"].stringValue
            
            locationDataModel.locationDataList.append(Location(name :  tempName,vicinity : tempVicinity, latitude : tempLatitude, longitude : tempLongitude , placeID : tempPlaceID))
        }
        print("doneUpdateLocationData")
    }
    
    func updateLocationDirectionData(json : JSON,destinationInfo : Location){
        print("updateLocationDirectionData")
        if let tempDistance = json["routes"][0]["legs"][0]["distance"]["value"].int {
            let tempDuration = json["routes"][0]["legs"][0]["duration"]["value"].intValue
        
            locationDirectionModel.locationDirectionList.append(LocationDirection(name : destinationInfo.name, latitude : destinationInfo.latitude, longitude : destinationInfo.longitude, distance : tempDistance, duration : tempDuration))
        }
        print("doneUpdateLocationDirectionData")
        
        tableView.reloadData()
    }

    
    
    //MARK: - TableView
    /***************************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(locationDirectionModel.locationDirectionList.count)")
        return locationDirectionModel.locationDirectionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        locationManager.startUpdatingLocation()

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       
        let distanceInKilometers = String(format :"%.1f",Double(locationDirectionModel.locationDirectionList[indexPath.row].distance)/1000.000)

        cell.textLabel?.text="\(locationDirectionModel.locationDirectionList[indexPath.row].name): \(distanceInKilometers)km \(locationDirectionModel.locationDirectionList[indexPath.row].duration)mins"
        
        //cell.textLabel?.text = "\(locationDataModel.locationDataList[indexPath.row].name)"
        
        return cell
    }

    //MARK: - TextField
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let maxLength = 6
//        let currentString: NSString = textField.text! as NSString
//        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length <= maxLength
        return range.location < 6
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}


