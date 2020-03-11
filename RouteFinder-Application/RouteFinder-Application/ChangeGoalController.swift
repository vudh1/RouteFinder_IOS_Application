//
//  ChangeGoalController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/8/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class ChangeGoalController : UIViewController, UITextFieldDelegate{
    @IBOutlet weak var changeGoalView: UIView!
    
    @IBOutlet weak var currentGoal: UILabel!
    
    @IBOutlet weak var enterGoal: UITextField!
    
    @IBOutlet weak var updateOutlet: UIButton!

    @IBOutlet weak var cancelOutlet: UIButton!
    
    @IBOutlet weak var DefaultOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.55)
       
        currentGoal.layer.masksToBounds = true
        currentGoal.layer.cornerRadius = 8.0
                
        enterGoal.layer.masksToBounds = true
        enterGoal.layer.cornerRadius = 8.0
        
        updateOutlet.layer.masksToBounds = true
        updateOutlet.layer.cornerRadius = 8.0
           
        cancelOutlet.layer.masksToBounds = true
        cancelOutlet.layer.cornerRadius = 8.0
        
        DefaultOutlet.layer.masksToBounds = true
        DefaultOutlet.layer.cornerRadius = 8.0
        
        //to close NumPad
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing)))
       }

    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - TextField
    /***************************************************************/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if  range.location >= MAX_DIGITS {
            return false //limit only 4 digits can be entered
        }
        
        //limit only numeric letters can be entered
        let compSepByCharInSet = string.components(separatedBy: NSCharacterSet(charactersIn:"0123456789").inverted)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        return string == numberFiltered
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
       
}

