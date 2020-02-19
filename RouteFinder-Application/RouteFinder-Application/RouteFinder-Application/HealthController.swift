//
//  HealthControllerViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/18/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class HealthController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        desiredDistance.keyboardType = UIKeyboardType.decimalPad

        desiredDistance.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNavigationController", sender: self)
    }
    
    @IBOutlet weak var desiredDistance: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNavigationController"{
            let destinationVC = segue.destination as! NavigationController
            
            if(desiredDistance.text!.isEmpty){
                destinationVC.desiredDistanceFromHealthController = "0"
            }
            else{
                destinationVC.desiredDistanceFromHealthController = desiredDistance.text!
            }
            
        }
    }

        //MARK: - TextField
    /***************************************************************/
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return range.location < 5
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
}
