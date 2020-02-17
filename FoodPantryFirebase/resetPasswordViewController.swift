//
//  resetPasswordViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/10/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
class resetPasswordViewController: UIViewController {

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.layer.cornerRadius = 15
        resetButton.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
         guard let emailaddress = emailTextField.text else { return }
        Auth.auth().sendPasswordReset(withEmail: emailaddress) { error in
            if error == nil {
                print("email successfully sent!")
                let alert = UIAlertController(title: "Password Reset Email Sent!", message: "Please check your email and follow the directions to reset your password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
            else{
                let alert = UIAlertController(title: "Error Occurred!", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
        }
    }
    

}
