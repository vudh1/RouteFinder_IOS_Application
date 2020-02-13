//
//  NearbyLocationDataModel.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/13/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//


import UIKit

class NearbyLocation {
    var name : String = ""
    var vicinity : String = ""
    var latitude : Double = 0
    var longitude : Double = 0
    var placeID : String = ""
    
    init(name : String, vicinity : String, latitude : Double, longitude : Double, placeID : String){
        self.name = name
        self.vicinity = vicinity
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
    }
}

class NearbyLocationDataModel {

    //Declare your model variables here
    var nearbyLocationData : [NearbyLocation] = []

}



