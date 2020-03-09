//
//  LocationCell.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/16/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import MapKit

protocol LocationCellDelegate{
    func didTapAppleMap(locationLatitude : Double,locationLongitude : Double, locationName : String, types : [String])
}

class LocationCell: UITableViewCell {

    var delegate : LocationCellDelegate?
    var locationName : String = ""
    var locationLatitude : Double = 0
    var locationLongitude : Double = 0
    var types : [String] = []
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var getDirectionOutlet: UIButton!
    @IBOutlet weak var appleMapOutlet: UIButton!

    func setLocationCellValues(infoParameters : [String:String],coordinateParameters : [String : Double], infoTypes : [String]){
        locationName = infoParameters["locationName"]!
        LocationLabel.text = infoParameters["locationName"]
        LocationLabel.layer.masksToBounds = true
        LocationLabel.layer.cornerRadius = 8.0
        
        DistanceLabel.text = infoParameters["locationDistance"]
        DistanceLabel.layer.masksToBounds = true
        DistanceLabel.layer.cornerRadius = 8.0

        DurationLabel.text = infoParameters["locationDuration"]
        DurationLabel.layer.masksToBounds = true
        DurationLabel.layer.cornerRadius = 8.0

        locationLatitude = coordinateParameters["locationLatitude"]!
        locationLongitude = coordinateParameters["locationLongitude"]!
        
        getDirectionOutlet.layer.masksToBounds = true
        getDirectionOutlet.layer.cornerRadius = 8.0
        
        appleMapOutlet.layer.masksToBounds = true
        appleMapOutlet.layer.cornerRadius = 8.0
        
        self.types = infoTypes
    }
    
    
    @IBAction func getDirectionPressed(_ sender: Any) {
        delegate?.didTapAppleMap(locationLatitude: locationLatitude, locationLongitude: locationLongitude, locationName: locationName, types: types)

    }
    
    @IBAction func appleMapPressed(_ sender: Any) {
        if var x = UserDefaults.standard.object(forKey: "POTENTIAL_PLACES") as? [String : [String]]{
            x[locationName] = types
            UserDefaults.standard.set(x, forKey: "POTENTIAL_PLACES")
        }
        else {
            var y : [String : [String]] = [:]
            y[locationName] = types
            UserDefaults.standard.set(y, forKey: "POTENTIAL_PLACES")
        }
        
        let appleLinkWithCoordinate = "http://maps.apple.com/?daddr=\(locationLatitude),\(locationLongitude)&dirflg=w"
        
        if let url = URL(string: appleLinkWithCoordinate){
                  UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    }
    
    
    //MARK:-
    
   
    
}
