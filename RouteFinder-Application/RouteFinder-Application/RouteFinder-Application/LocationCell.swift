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
    func didTapAppleMap(url : String)
}

class LocationCell: UITableViewCell {

    var delegate : LocationCellDelegate?
    var locationCoordinate : String = ""
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var DurationLabel: UILabel!

    func setLocationCellValues(parameters : [String:String]){
        LocationLabel.text = parameters["locationName"]
        DistanceLabel.text = parameters["locationDistance"]
        DurationLabel.text = parameters["locationDuration"]
        locationCoordinate = parameters["locationCoordinate"]!
    }
    
    @IBAction func AppleMap(_ sender: UIButton) {
        
        //let locationName = LocationLabel.text!.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                
        let appleLinkWithCoordinate = "http://maps.apple.com/?daddr=\(locationCoordinate)&dirflg=w"

        delegate?.didTapAppleMap(url: appleLinkWithCoordinate)

        if let url = URL(string: appleLinkWithCoordinate){
            UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    }
    
}
