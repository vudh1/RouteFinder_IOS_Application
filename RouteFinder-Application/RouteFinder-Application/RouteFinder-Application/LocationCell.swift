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
    
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var DurationLabel: UILabel!

    func setLocationCellValues(parameters : [String:String]){
        LocationLabel.text = parameters["locationName"]
        DistanceLabel.text = parameters["locationDistance"]
        DurationLabel.text = parameters["locationDuration"]
    }
    
    @IBAction func AppleMap(_ sender: UIButton) {
        let locationName = LocationLabel.text!.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                
        let appleLink = "http://maps.apple.com/?daddr=\(locationName)&dirflg=w"
        
        delegate?.didTapAppleMap(url: appleLink)

        if let url = URL(string: appleLink) {
            UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    }
    
}
