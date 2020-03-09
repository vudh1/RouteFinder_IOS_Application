//
//  LocationTypeCell.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/8/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

protocol LocationTypeCellDelegate{
    func didTapHeart(isLoved : Bool, cellIndex : Int)
}

class LocationTypeCell : UITableViewCell {
    var delegate : LocationTypeCellDelegate?
    var isLoved : Bool = false
    var cellIndex : Int = 0
    
    @IBOutlet weak var LocationTypeOutlet: UILabel!
    
    @IBOutlet weak var HeartOutlet: UIButton!
    
    @IBAction func choosePressed(_ sender: Any) {
        if !isLoved {
            HeartOutlet.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            isLoved = true
        }
        else {
            HeartOutlet.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            isLoved = false
        }
        
        delegate?.didTapHeart(isLoved: isLoved, cellIndex: cellIndex)
    }
    
    @IBAction func HeartPressed(_ sender: Any) {
        if !isLoved {
            HeartOutlet.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            isLoved = true
        }
        else {
            HeartOutlet.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            isLoved = false
        }
        
        delegate?.didTapHeart(isLoved: isLoved, cellIndex: cellIndex)
    }
    
    
    
}
