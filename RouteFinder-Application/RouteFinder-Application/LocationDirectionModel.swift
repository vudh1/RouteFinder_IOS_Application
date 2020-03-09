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
    var types : [String] = []
    var rating : Int = 0
    var distance : Int = 0 //meters
    var duration : Int = 0 //seconds
        
    init(name : String, latitude : Double, longitude : Double ,distance : Int, duration : Int, types : [String], rating : Int){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
        self.duration = duration
        self.types = types
        self.rating = rating
    }
}

class LocationDirectionModel {

    //Declare your model variables here
    var locationDirectionList : [LocationDirection] = []

    //MARK: - Sorting Algorithm Using Binary Search
    /***************************************************************/

    func sortLocationDirectionList(desiredDistance : Int, sortingOption : Int) {
        if locationDirectionList.count<=1{
            return
        }
        
        switch sortingOption{

        case 0: // sort by current location
            for i in 1...locationDirectionList.count-1{
                var j : Int = i-1
                let selected = locationDirectionList[i]
                
                let loc = binarySearchForDistance(list: locationDirectionList, item: selected, low: 0, high: j, desiredDistance: 0)
                
                while j >= loc {
                    locationDirectionList[j+1]=locationDirectionList[j]
                    j-=1
                }
                
                locationDirectionList[j+1] = selected
            }
            
        case 1: // sort by goal distance
            for i in 1...locationDirectionList.count-1{
                var j : Int = i-1
                let selected = locationDirectionList[i]
                
                let loc = binarySearchForDistance(list: locationDirectionList, item: selected, low: 0, high: j, desiredDistance: desiredDistance)
                
                while j >= loc {
                    locationDirectionList[j+1]=locationDirectionList[j]
                    j-=1
                }
                
                locationDirectionList[j+1] = selected
            }
            
        case 2: // sort by rating of location
              for i in 0...locationDirectionList.count-1 {
                print(locationDirectionList[i].types,locationDirectionList[i].rating)
            }
              for i in 1...locationDirectionList.count-1{
                  var j : Int = i-1
                  let selected = locationDirectionList[i]
                  
                  let loc = binarySearchForRating(list: locationDirectionList, item: selected, low: 0, high: j)
                  
                  while j >= loc {
                      locationDirectionList[j+1]=locationDirectionList[j]
                      j-=1
                  }
                  
                  locationDirectionList[j+1] = selected
              }
        
              for i in 0...locationDirectionList.count-1 {
                print(locationDirectionList[i].types,locationDirectionList[i].rating)
            }
        default:
            return
        }
    }
    
    //MARK: - Binary Search Algorithm
    /***************************************************************/

    func binarySearchForDistance(list : [LocationDirection], item : LocationDirection, low : Int, high : Int, desiredDistance : Int) -> Int{
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
            return binarySearchForDistance(list: list, item: item, low: mid+1, high: high, desiredDistance: desiredDistance)
        }
        
        return binarySearchForDistance(list: list, item: item, low: low, high: mid-1, desiredDistance: desiredDistance)
    }
    
    func binarySearchForRating(list : [LocationDirection], item : LocationDirection, low : Int, high : Int) -> Int{
           if high <= low {
            if item.rating < list[low].rating {
                   return low + 1
               }
               else {
                   return low
               }
           }
           
           let mid = (low+high)/2
           
        if item.rating == list[mid].rating {
               return mid+1
           }
           
        if item.rating < list[mid].rating {
               return binarySearchForRating(list: list, item: item, low: mid+1, high: high)
           }
           
           return binarySearchForRating(list: list, item: item, low: low, high: mid-1)
       }
}


