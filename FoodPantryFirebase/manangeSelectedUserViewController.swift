//
//  manangeSelectedUserViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 4/9/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase
import FirebaseAuth

class manageSelectedUserViewController: UIViewController {
    
    var PantryName: String = ""
    var ref: DatabaseReference! //reference to the firebase database
    
    @IBOutlet var popOverView: UIView!
    @IBOutlet var nameLabel: UILabel!
    
    var name: String = ""
    var status: String = ""
    var uid: String = ""
    var email: String = ""
    var password: String = ""
    
    var adminEmail = ""
    var adminPassword = ""
    
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var approveButton: UIButton!
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var suspendButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        popOverView.layer.cornerRadius = 15
        popOverView.clipsToBounds = true
        
        buttonConstraints()

        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
    
        nameLabel.text = name
        
        //get the admins email + password
        
        let userID = Auth.auth().currentUser!.uid
        
        ref.child(self.PantryName).child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        let value = snapshot.value as? NSDictionary
          self.adminEmail = value?["Email Address"] as? String ?? "" //loads in the code from firebase
            self.adminPassword = value?["Password"] as? String ?? ""
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        
        updateButtons(status: self.status)
        
    }
    
    func buttonConstraints() {
        resetButton.layer.cornerRadius = 15
        resetButton.clipsToBounds = true
        
        resetButton.titleLabel?.minimumScaleFactor = 0.5
        resetButton.titleLabel?.numberOfLines = 1;
        resetButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        approveButton.layer.cornerRadius = 15
        approveButton.clipsToBounds = true
        
        approveButton.titleLabel?.minimumScaleFactor = 0.5
        approveButton.titleLabel?.numberOfLines = 1;
        approveButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        resumeButton.layer.cornerRadius = 15
        resumeButton.clipsToBounds = true
        
        resumeButton.titleLabel?.minimumScaleFactor = 0.5
        resumeButton.titleLabel?.numberOfLines = 1;
        resumeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        suspendButton.layer.cornerRadius = 15
        suspendButton.clipsToBounds = true
        
        suspendButton.titleLabel?.minimumScaleFactor = 0.5
        suspendButton.titleLabel?.numberOfLines = 1;
        suspendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        deleteButton.layer.cornerRadius = 15
        deleteButton.clipsToBounds = true
        
        deleteButton.titleLabel?.minimumScaleFactor = 0.5
        deleteButton.titleLabel?.numberOfLines = 1;
        deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    

    
    @IBAction func resetPassword(_ sender: Any) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if error == nil {
                    //If no error, then email for recovery with instructions is sent-manage email strucutre in firebase
                    let alert = UIAlertController(title: "Password Reset Email Sent!", message: "Please tell the user to check their email and follow the directions to reset their password!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil);
                    //above shows alert for successfull sent of message
                }
                else{
                    let alert = UIAlertController(title: "Error Occurred!", message: "Incorrect email, please try again.", preferredStyle: .alert)//displays alert of erRor!
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil);
                    //If email does not exist, then error message appears
                }
            }
    }
    
    @IBAction func approveUser(_ sender: Any) {
        
        
        self.ref.child("All Users").child(self.uid).child("Account Status").setValue("1")
        
        let alert = UIAlertController(title: "Updated!", message: "User has been approved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
        
        updateButtons(status: "1")

    }
    
    @IBAction func resumeUser(_ sender: Any) {
        self.ref.child("All Users").child(self.uid).child("Account Status").setValue("1")
        
        let alert = UIAlertController(title: "Updated!", message: "User is no longer suspended.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
        updateButtons(status: "1")
    }
    
    @IBAction func suspendUser(_ sender: Any) {
        
        self.ref.child("All Users").child(self.uid).child("Account Status").setValue("2")
        
        let alert = UIAlertController(title: "Updated!", message: "User has been suspended.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
        updateButtons(status: "2")
    }
    
    @IBAction func deleteUser(_ sender: Any) {
        
        //Firbase only allows you to delete the account of the current user when using it client side
        //In order to make it easier, we can just sign the deleted user in, delete them, and then sign the admin back in
        
        
        //first, remove firebase data for the user
        
        let ref = self.ref.child(PantryName).child("Users").child(uid)

        ref.removeValue { error, _ in

            if(error == nil) {
                
                self.removeMoreData()
                
            } else {
                let alert = UIAlertController(title: "Error!", message: "Please try again.", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
        }
        
    }
    
    func removeMoreData() {
        let ref2 = self.ref.child("All Users").child(self.uid)
        
         ref2.removeValue { error, _ in
            
            if(error == nil) {
            
            try! Auth.auth().signOut()
            
                Auth.auth().signIn(withEmail: self.email, password: self.password){ user, error in
                    if(error != nil) {
                        let alert = UIAlertController(title: "Error!", message: "Please try again.", preferredStyle: .alert)//displays alert of erRor!
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil);
                    } else {
                        let user = Auth.auth().currentUser

                        user?.delete { error in
                            if let error = error {
                                let alert = UIAlertController(title: "Error!", message: "Please try again.", preferredStyle: .alert)//displays alert of erRor!
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil);
                            } else {
                                // Account deleted.
                        
                                //sign the admin back in
                                self.signBackIn()
                        
                            }
                        }
                    }
                }
            
            } else {
                let alert = UIAlertController(title: "Error!", message: "Please try again.", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
        }
    }
    
    func signBackIn() {
        try! Auth.auth().signOut()
        
        Auth.auth().signIn(withEmail: self.adminEmail, password: self.adminPassword){ user, error in
            if(error != nil) {
                let alert = UIAlertController(title: "Error!", message: "Please try again.", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            } else {
                let alert = UIAlertController(title: "Updated!", message: "User has been deleted.", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                self.updateButtons(status: "3")
            }
        }

    }
    
    func updateButtons(status: String) {
        print(status)
        if(status == "0") { //not approved
            approveButton.isEnabled = true
            resumeButton.isEnabled = false
            suspendButton.isEnabled = false
            deleteButton.isEnabled = true
            resetButton.isEnabled = true
            
            approveButton.alpha = 1.0
            resumeButton.alpha = 0.5
            suspendButton.alpha = 0.5
            deleteButton.alpha = 1.0
            resetButton.alpha = 1.0
        } else if(status == "1") { //approved
            approveButton.isEnabled = false
            resumeButton.isEnabled = false
            suspendButton.isEnabled = true
            deleteButton.isEnabled = true
            resetButton.isEnabled = true
            
            approveButton.alpha = 0.5
            resumeButton.alpha = 0.5
            suspendButton.alpha = 1.0
            deleteButton.alpha = 1.0
            resetButton.alpha = 1.0
        } else if(status == "2") { //suspended
            approveButton.isEnabled = false
            resumeButton.isEnabled = true
            suspendButton.isEnabled = false
            deleteButton.isEnabled = true
            resetButton.isEnabled = true
            
            approveButton.alpha = 0.5
            resumeButton.alpha = 1.0
            suspendButton.alpha = 0.5
            deleteButton.alpha = 1.0
            resetButton.alpha = 1.0
            
        } else if(status == "3") {
            approveButton.isEnabled = false
            resumeButton.isEnabled = false
            suspendButton.isEnabled = false
            deleteButton.isEnabled = false
            resetButton.isEnabled = false
            
            approveButton.alpha = 0.5
            resumeButton.alpha = 0.5
            suspendButton.alpha = 0.5
            deleteButton.alpha = 0.5
            resetButton.alpha = 0.5
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //as anothe way of dismissing the view, outside the view
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if !popOverView.frame.contains(location) {
            print("Tapped outside the view")
            self.performSegue(withIdentifier: "GoBack", sender: self)
        }else {
            print("Tapped inside the view")
        }
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.performSegue(withIdentifier: "GoBack", sender: self)
    }
}
