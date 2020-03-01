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
        //creating rounded buttons below
        resetButton.layer.cornerRadius = 15
        resetButton.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        //Purpose of function is to send the reset password email to auth email
        guard let emailaddress = emailTextField.text else { return }//gets users email
        Auth.auth().sendPasswordReset(withEmail: emailaddress) { error in
            if error == nil {
                //If no error, then email for recovery with instructions is sent
                print("email successfully sent!")
                let alert = UIAlertController(title: "Password Reset Email Sent!", message: "Please check your email and follow the directions to reset your password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                //above shows alert for successfull sent of message
            }
            else{
                let alert = UIAlertController(title: "Error Occurred!", message: "Please try again!", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                //If email does not exist, then error message appears
            }
        }
    }
    

}
