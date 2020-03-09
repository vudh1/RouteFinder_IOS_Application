//
//  LocationHistoryController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/8/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class LocationHistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var nameList : [String] = []
    var typeList : [String] = []
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        if let x = UserDefaults.standard.object(forKey: "POTENTIAL_PLACES") as? [String : [String]] {
                    
            for(name,types) in x{
                nameList.append(name)
                
                var temp : String = ""
                
                for i in 0...types.count-1 {
                    temp += types[i]
                    if i < types.count-1 {
                        temp += ", "
                    }
                }
                typeList.append(temp)
            }
        }
    
        tableView.delegate = self
        tableView.reloadData()
    }
}
