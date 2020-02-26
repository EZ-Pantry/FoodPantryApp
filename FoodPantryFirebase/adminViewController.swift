//
//  adminViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/20/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class adminViewController: UIViewController {

    @IBOutlet weak var adminCodeTxtField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        guard let adminCodeEntered = adminCodeTxtField.text else { return }
        
        if(adminCodeEntered == "SXY106"){
            self.performSegue(withIdentifier: "toAdminControls", sender: nil)
        }
        else{
            let alert = UIAlertController(title: "Incorrect Credentials", message: "Please try again!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil);
        }
    }
    
}
