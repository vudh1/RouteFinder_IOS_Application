//
//  MainViewController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 3/6/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    var defaultGoal : Int = 0
    
    @IBOutlet weak var GetLocationsOutlet: UIButton!

    @IBAction func GetLocationsPressed(_ sender: Any) {
        let changeGoalVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(identifier: "enterDistanceID") as! HealthController
        self.addChild(changeGoalVC)
        changeGoalVC.view.frame = self.view.frame
        self.view.addSubview(changeGoalVC.view)
        changeGoalVC.enterDistanceView.layer.masksToBounds = true
        changeGoalVC.enterDistanceView.layer.cornerRadius = 8.0
        
        changeGoalVC.CurrentGoal.text = "Current Goal\n\(String(defaultGoal))"
        changeGoalVC.CurrentGoal.layer.masksToBounds = true
        changeGoalVC.CurrentGoal.layer.cornerRadius = 8.0
        changeGoalVC.didMove(toParent: self)
    }
    
    @IBOutlet weak var GetHealthInformation: UIButton!

    @IBAction func GetHealthInformation(_ sender: Any) {
        performSegue(withIdentifier: "goToHealthDataController", sender: self)
    }

    
    //MARK: - Segue
    /***************************************************************/

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "goToHealthDataController"{
                   let destinationVC = segue.destination as! HealthDataController
                   
                   destinationVC.defaultGoal = defaultGoal
               }
    }
    
    @IBAction func unwindToMainControllerFromHealthData(_sender : UIStoryboardSegue){
        if let x = UserDefaults.standard.object(forKey: "UserGoal") as? String
        {
            defaultGoal = Int(x)!
        }
    }
    
    @IBAction func unwindToMainControllerFromMap(_sender : UIStoryboardSegue){
    }

    /***************************************************************/

    override func viewDidLoad() {
        super.viewDidLoad()

        GetLocationsOutlet.layer.masksToBounds = true
        GetLocationsOutlet.layer.cornerRadius = 8.0
           
        GetHealthInformation.layer.masksToBounds = true
        GetHealthInformation.layer.cornerRadius = 8.0
        
       }

       override func didReceiveMemoryWarning() {
              super.didReceiveMemoryWarning()
       }
    
    override func viewDidAppear(_ animated: Bool) {
        if let x = UserDefaults.standard.object(forKey: "UserGoal") as? String {
            defaultGoal = Int(x)!
        }
    }

}
