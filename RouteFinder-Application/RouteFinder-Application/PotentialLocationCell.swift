//
//  PotentialLocationCell.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/8/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class PotentialLocationCell: UITableViewCell {
    var locationName : String = ""
    
    @IBOutlet weak var LocationNameLabel: UILabel!
    
    @IBOutlet weak var LocationTypesLabel: UILabel!
    
    @IBAction func goToAppleMapPressed(_ sender: Any) {
        let newString = locationName.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        let appleLinkWithCoordinate = "http://maps.apple.com/?q=\(newString)"
               
               if let url = URL(string: appleLinkWithCoordinate){
                         UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    }
}
