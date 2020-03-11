//
//  LocationHistoryController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/8/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class LocationHistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var historyList : [String : HistoryData] = [:]
    var nameList : [String] = []
    var typeList : [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nameList.count > MAX_CELL {
           return MAX_CELL
        }
        
        return nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "potentialLocationCell", for: indexPath) as! PotentialLocationCell
        cell.locationName = nameList[indexPath.row]
        
        cell.LocationNameLabel.layer.masksToBounds = true
        cell.LocationNameLabel.layer.cornerRadius = 8.0
        cell.LocationNameLabel.text = nameList[indexPath.row]
        
        cell.LocationTypesLabel.layer.masksToBounds = true
        cell.LocationTypesLabel.layer.cornerRadius = 8.0
        cell.LocationTypesLabel.text = typeList[indexPath.row]
    
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let x = UserDefaults.standard.object(forKey: "POTENTIAL_PLACES") as? [String : Data] {
            
            for (name,encodedData) in x {
                do {
                    if let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedData) as? HistoryData {
                        historyList[name] = data
                    }
                } catch {
                    print("Couldn't read file.")
                }
            }
            
            let sortedList = historyList.sorted { $0.1.time > $1.1.time }

            for(key,value) in sortedList{
                nameList.append(key)
                var temp : String = ""
                
                for i in 0...value.types.count-1 {
                    if (LOCATION_TYPE.contains(value.types[i])) {
                        let newString = value.types[i].replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
                        let newString1 = newString.replacingOccurrences(of: " or ", with: ", ", options: .literal, range: nil)
                        temp += " \(newString1),"
                    }
                }
                
                temp.removeLast()
                
                typeList.append(temp)
            }
        }
    
        tableView.delegate = self
        tableView.reloadData()
    }
}
