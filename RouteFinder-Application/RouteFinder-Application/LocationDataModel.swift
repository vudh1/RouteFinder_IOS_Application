//
//  NearbyLocationDataModel.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/13/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//


import UIKit

class Location {
    var name : String = ""
    var vicinity : String = ""
    var latitude : Double = 0
    var longitude : Double = 0
    var placeID : String = ""
    var types : [String] = []
    var rating : Int = 0
    
    init(name : String, vicinity : String, latitude : Double, longitude : Double, placeID : String, types : [String], rating : Int){
        self.name = name
        self.vicinity = vicinity
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
        self.types = types
        self.rating = rating
    }
}

class LocationDataModel {
    var locationDataList : [String : Location] = [:]
}



