//
//  HealthControllerViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/18/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import HealthKit

class HealthController: UIViewController, UITextFieldDelegate {
    
    var reccomendGoal : String = ""
    
    @IBOutlet weak var enterDistanceView: UIView!
    
    @IBOutlet weak var CurrentGoal: UILabel!
    
    let MAX_DIGITS = 4
    
    let locationTypes = ["library","cafe","park","shopping_mall","tourist_attraction"]
    
    @IBOutlet weak var desiredDistance: UITextField! // textField for goal distance

    @IBOutlet weak var searchLocationsOutlet: UIButton! //outlet of Search Location Button
    
    @IBAction func searchLocationsPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNavigationController", sender: self)
        self.view.removeFromSuperview()
    }
    
    @IBOutlet weak var cancelOutlet: UIButton!
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
     
    
    //MARK: - Segue
    /***************************************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNavigationController"{
            let destinationVC = segue.destination as! NavigationController
            
            destinationVC.LOCATION_TYPE = locationTypes
            
            if(desiredDistance.text!.isEmpty){
                destinationVC.desiredDistanceFromHealthController = "0"
            }
            else{
                destinationVC.desiredDistanceFromHealthController = desiredDistance.text!
            }
        }
        
        else if segue.identifier == "goToHealthDataController"{
            let destinationVC = segue.destination as! HealthDataController
            
            destinationVC.dailyDistance = Int(desiredDistance.text!)!
            
            print("return back to Health Data Controller")
        }
    }

    @IBAction func unwindToHealthController(_sender : UIStoryboardSegue){    }


    /***************************************************************/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        desiredDistance.layer.masksToBounds = true
        desiredDistance.layer.cornerRadius = 8.0
        desiredDistance.keyboardType = UIKeyboardType.decimalPad
        desiredDistance.delegate = self

        searchLocationsOutlet.layer.masksToBounds = true
        searchLocationsOutlet.layer.cornerRadius = 8.0
        
        cancelOutlet.layer.masksToBounds = true
        cancelOutlet.layer.cornerRadius = 8.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let x = UserDefaults.standard.object(forKey: "UserGoal") as? String {
            reccomendGoal = x
            CurrentGoal.text = "Current Goal\n\(String(reccomendGoal))"
        }
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
