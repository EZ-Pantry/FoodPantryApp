//
//  logInViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/8/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class logInViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded buttons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    

    
    

    @IBAction func handleContinue(_ sender: UIButton) {
        guard let emailaddress = emailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        print(password)
        Auth.auth().signIn(withEmail: emailaddress, password: password){ user, error in
            if error == nil && user != nil{
                self.dismiss(animated: false, completion: nil)
                //If email & password exist, then sign in
            }
            else{
                //else show error message
                let alert = UIAlertController(title: "Error Logging In", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
        }
        
    }
    
    
    @IBAction func dismissToLoginScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
