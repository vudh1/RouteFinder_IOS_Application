//
//  HistoryData.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/9/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import Foundation

class HistoryData : NSObject, NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(self.locationName, forKey: "locationName")
        coder.encode(self.types, forKey: "types")
        coder.encode(self.time, forKey: "time")
    }
    
    required convenience init?(coder: NSCoder) {
        guard let locationName = coder.decodeObject(forKey: "locationName") as? String
        else { return nil }
        
        self.init(
            locationName: locationName,
            types : coder.decodeObject(forKey: "types") as! [String],
            time : coder.decodeDouble(forKey: "time")
        )
    }
    
    var locationName : String = ""
    var types : [String] = []
    var time : Double = 0.0
    
    init(locationName : String, types : [String] ,time : Double){
        self.locationName = locationName
        self.types = types
        self.time = time
    }
}
