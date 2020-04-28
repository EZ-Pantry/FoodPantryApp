//
//  passwordResetViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/15/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
class passwordResetViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var emailAddressTextField: UITextField!
    var activeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        //make buttons rounded
        resetPasswordButton.layer.cornerRadius = 15
        resetPasswordButton.clipsToBounds = true
        
        //make sure button text fits all screens
        resetPasswordButton.titleLabel?.minimumScaleFactor = 0.5
        resetPasswordButton.titleLabel?.numberOfLines = 1;
        resetPasswordButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(passwordResetViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(passwordResetViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailAddressTextField.delegate = self;
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resetPasswordHandler();
    }
    
    func resetPasswordHandler(){
        //Purpose of function is to send the reset password email to auth email
        guard let emailaddress = emailAddressTextField.text else { return }//gets users email
        Auth.auth().sendPasswordReset(withEmail: emailaddress) { error in
            if error == nil {
                //If no error, then email for recovery with instructions is sent-manage email strucutre in firebase
                print("email successfully sent!")
                let alert = UIAlertController(title: "Password Reset Email Sent!", message: "Please check your email and follow the directions to reset your password!", preferredStyle: .alert)
                UserDefaults.standard.set("Bad", forKey: "Times Unlocked")
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                //above shows alert for successfull sent of message
            }
            else{
                let alert = UIAlertController(title: "Error Occurred!", message: "Please enter the correct email!", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                //If email does not exist, then error message appears
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(true)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
            
        func textFieldDidBeginEditing(_ textField: UITextField){
            self.activeField = textField
        }


         @objc func keyboardWillShow(notification: NSNotification) {
                   if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                       
                       let first = (self.activeField?.frame.origin.y) ?? -1
                       
                       if(first != -1) {
                           if (self.activeField?.frame.origin.y)! >= keyboardSize.height {
                               self.view.frame.origin.y = keyboardSize.height - (self.activeField?.frame.origin.y)!
                           } else {
                               self.view.frame.origin.y = 0
                           }
                       }
                       
                   }
               }

        @objc func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 0
        }
    

}
