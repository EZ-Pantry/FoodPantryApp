//
//  emailVerificationViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/15/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
class emailVerificationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sendEmailVerificationButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    var activeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        //create rounded buttons
        sendEmailVerificationButton.layer.cornerRadius = 15
        sendEmailVerificationButton.clipsToBounds = true
        //make sure button text fits all screen sizes
        sendEmailVerificationButton.titleLabel?.minimumScaleFactor = 0.5
        sendEmailVerificationButton.titleLabel?.numberOfLines = 1;
        sendEmailVerificationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //add observers
         NotificationCenter.default.addObserver(self, selector: #selector(emailVerificationViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(emailVerificationViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailAddressTextField.delegate = self;
        passwordTextField.delegate = self;
    }

    @IBAction func sendEmailVerificationButtonTapped(_ sender: UIButton) {
        sendEmailVerificationHandler();
    }
    
    func sendEmailVerificationHandler(){
        guard let emailaddress = emailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: emailaddress, password: password){ user, error in
            
            if(error != nil) {
                print(error)
                //else show error message
                let alert = UIAlertController(title: "Error Occured!", message: "Please enter the correct email and password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            } else {
            
                    let user = Auth.auth().currentUser
                        if(!user!.isEmailVerified) {
                        user!.sendEmailVerification(completion: { (error) in
                            print("sent verification")
                            if(error == nil) {
                                //email verification link is sent again
                                let alert = UIAlertController(title: "Email Sent", message: "The verification email has been sent. Check your inbox!", preferredStyle: .alert)
                                UserDefaults.standard.set("Bad", forKey: "Times Unlocked")
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil);
                            } else {
                                print(error)
                                // the user is not available-error display
                                let alert = UIAlertController(title: "Error", message: "Please try again!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil);
                            }


                        })

                        } else {
                            let alert = UIAlertController(title: "Already Verified", message: "This account is already verified. If you cannot login, please contact the admin.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil);
                        }
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
