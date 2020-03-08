//
//  SetLocationTypeController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/8/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class SetLocationTypeController: UIViewController, LocationTypeCellDelegate, UITableViewDelegate, UITableViewDataSource {
    var LOCATION_TYPE : [String] = []
    var LOCATION_TYPE_LOVE : [Bool] = []
    
    func didTapLike(isLiked: Bool, cellIndex : Int) {
        LOCATION_TYPE_LOVE[cellIndex] = isLiked
        UserDefaults.standard.set(LOCATION_TYPE_LOVE, forKey: "LOCATION_TYPE_LOVE")
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("LOCATION_TYPE_LOVE: \(LOCATION_TYPE_LOVE.count)")
        return LOCATION_TYPE.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationTypeCell", for: indexPath) as! LocationTypeCell
        
        cell.delegate = self
        
        cell.cellIndex = indexPath.row
        
        if LOCATION_TYPE_LOVE[indexPath.row] {
            cell.HeartOutlet.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            cell.isLiked = true
        }
        else {
            cell.HeartOutlet.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            cell.isLiked = false
        }
        
        cell.LocationTypeOutlet.text = LOCATION_TYPE[indexPath.row]
        
        return cell
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let x = UserDefaults.standard.object(forKey: "LOCATION_TYPE") as? [String] {
            LOCATION_TYPE = x
        }
        
        if let x = UserDefaults.standard.object(forKey: "LOCATION_TYPE_LOVE") as? [Bool] {
            LOCATION_TYPE_LOVE = x
        }
        
        tableView.delegate = self
        tableView.reloadData()
    }

}
