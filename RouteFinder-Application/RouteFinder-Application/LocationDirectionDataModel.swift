//
//  LocationDirectionDataModel.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/13/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class nearbyLocationDirection {
    var name : String = ""
    var latitude : Double = 0
    var longitude : Double = 0
    
    var distance : Int = 0 //meters
    var duration : Int = 0 //seconds
    
    init(name : String, latitude : Double, longitude : Double ,distance : Int, duration : Int){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
        self.duration = duration
    }
}

class LocationDirectionDataModel {

    //Declare your model variables here
    var locationDirectionDataList : [nearbyLocationDirection] = []

}


