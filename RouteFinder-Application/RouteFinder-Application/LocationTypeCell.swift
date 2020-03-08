//
//  LocationTypeCell.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/8/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

protocol LocationTypeCellDelegate{
    func didTapLike(isLiked : Bool, cellIndex : Int)
}

class LocationTypeCell : UITableViewCell {
    var delegate : LocationTypeCellDelegate?
    var isLiked : Bool = false
    var cellIndex : Int = 0
    
    @IBOutlet weak var LocationTypeOutlet: UILabel!
    
    @IBOutlet weak var HeartOutlet: UIButton!
    
    @IBAction func HeartPressed(_ sender: Any) {
        if !isLiked {
            HeartOutlet.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            isLiked = true
        }
        else {
            HeartOutlet.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            isLiked = false
        }
        
        delegate?.didTapLike(isLiked: isLiked, cellIndex: cellIndex)
    }
    
}
