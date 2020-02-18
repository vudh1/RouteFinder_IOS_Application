//
//  LocationDirectionDataModel.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/13/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class LocationDirection {
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

class LocationDirectionModel {

    //Declare your model variables here
    var locationDirectionList : [LocationDirection] = []

    func sortLocationDirectionList(desiredDistance : Int) {
        if locationDirectionList.count<=1{
            return
        }
                
        for i in 1...locationDirectionList.count-1{
            var j : Int = i-1
            let selected = locationDirectionList[i]
            
            let loc = binarySearch(list: locationDirectionList, item: selected, low: 0, high: j, desiredDistance: desiredDistance)
            
            while j >= loc {
                locationDirectionList[j+1]=locationDirectionList[j]
                j-=1
            }
            
            locationDirectionList[j+1] = selected
        }
    }
    
    func binarySearch(list : [LocationDirection], item : LocationDirection, low : Int, high : Int, desiredDistance : Int) -> Int{
        if high <= low {
            if abs(item.distance-desiredDistance) > abs(list[low].distance-desiredDistance) {
                return low + 1
            }
            else {
                return low
            }
        }
        
        let mid = (low+high)/2
        
        if abs(item.distance-desiredDistance) == abs(list[mid].distance-desiredDistance) {
            return mid+1
        }
        
        if abs(item.distance-desiredDistance) > abs(list[mid].distance-desiredDistance) {
            return binarySearch(list: list, item: item, low: mid+1, high: high, desiredDistance: desiredDistance)
        }
        
        return binarySearch(list: list, item: item, low: low, high: mid-1, desiredDistance: desiredDistance)
    }

}


