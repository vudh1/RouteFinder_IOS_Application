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
    func didTapAppleMap(locationLatitude : Double,locationLongitude : Double, locationName : String )
}

class LocationCell: UITableViewCell {

    var delegate : LocationCellDelegate?
    var locationLatitude : Double = 0
    var locationLongitude : Double = 0
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var getDirectionOutlet: UIButton!
    @IBOutlet weak var appleMapOutlet: UIButton!

    func setLocationCellValues(infoParameters : [String:String],coordinateParameters : [String : Double]){
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
    }
    
    
    @IBAction func getDirectionPressed(_ sender: Any) {
        delegate?.didTapAppleMap(locationLatitude: locationLatitude, locationLongitude: locationLongitude, locationName: LocationLabel.text!)
        
    }
    
    @IBAction func appleMapPressed(_ sender: Any) {
        let appleLinkWithCoordinate = "http://maps.apple.com/?daddr=\(locationLatitude),\(locationLongitude)&dirflg=w"
        
        if let url = URL(string: appleLinkWithCoordinate){
                  UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    }
    
    
    //MARK:-
    
   
    
}
