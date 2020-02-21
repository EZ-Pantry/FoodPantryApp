//
//  SignUpViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/8/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import FirebaseDatabase
class SignUpViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var schoolID: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    
    @IBOutlet weak var schoolCodeTextField: UITextField!
    
    @IBOutlet weak var adminCodeTextField: UITextField!
    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!
    
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var selectSchoolButton: UIButton!
    @IBOutlet weak var firstSchoolButton: UIButton!
    
    var ref: DatabaseReference!

    var schoolName: String = ""
    
    var correctSchoolCodeEntered = false;
    var isAdmin = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        selectSchoolButton.layer.cornerRadius = 15
        selectSchoolButton.clipsToBounds = true
        firstSchoolButton.layer.cornerRadius = 15
        firstSchoolButton.clipsToBounds = true
        studentButton.layer.cornerRadius = 15
        studentButton.clipsToBounds = true
        adminButton.layer.cornerRadius = 15
        adminButton.clipsToBounds = true
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func handleSelection(_ sender: UIButton){
        //code below for multiple schools added
//        firstSchoolButton.forEach { (button) in
//            butt
//        }
        
        UIView.animate(withDuration: 0.7, animations: {
            self.firstSchoolButton.isHidden = !self.firstSchoolButton.isHidden;//change to opposite state
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func schoolTapped(_ sender: UIButton) {
        guard let schoolTitle = sender.currentTitle else{
            return;
        }
        
        schoolName = schoolTitle;
        schoolCodeTextField.isHidden = false;
    }
    
    
    @IBAction func studentButtonTapped(_ sender: UIButton) {
        adminCodeTextField.isHidden = true;
    }
    
    @IBAction func adminButtonTapped(_ sender: UIButton) {
        adminCodeTextField.isHidden = false;
    }
    
    
    //Codes Below
    //Conant: CHSGO10
    //Admin: SXY106
    let conantSchoolCode = "CHSGO10"
    let adminCode = "SXY106"
    
    
    @IBAction func handleContinue(_ sender: UIButton) {
        guard let fullname = fullNameTextField.text else { return }
        guard let schoolIDNumber = schoolID.text else { return }
        guard let emailaddress = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let allergies = allergiesTextField.text else { return }
        guard let schoolCodeEntered = schoolCodeTextField.text else { return }
        guard let adminCodeEntered = adminCodeTextField.text else { return }
        
        if(schoolName == "Conant High School"){
            if(schoolCodeEntered == conantSchoolCode){
                correctSchoolCodeEntered = true;
                print("correct1")
            }
//            else{
//                let alert = UIAlertController(title: "Incorrect School Code", message: "Please try again!", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil);
//            }
        }
        
        if(adminCodeEntered == adminCode){
            isAdmin = true;
            print("correct2")
        }
//        else{
//            let alert = UIAlertController(title: "Incorrect Admin Code", message: "Please try again!", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil);
//        }
        
        if(correctSchoolCodeEntered){
            Auth.auth().createUser(withEmail: emailaddress, password: password){ user, error in
                if error == nil && user != nil{
                    print("User Created")
                    if(self.isAdmin){
                    self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Name").setValue(fullname)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("ID Number ").setValue(schoolIDNumber)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Password ").setValue(password)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Allergies ").setValue(allergies)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Admin ").setValue("Yes")
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Total Item's Checked Out ").setValue("0")
                    }
                    else{
                    self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Name").setValue(fullname)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("ID Number ").setValue(schoolIDNumber)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Password ").setValue(password)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Allergies ").setValue(allergies)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Admin ").setValue("No")
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Total Item's Checked Out ").setValue("0")
                    }
                    
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    let alert = UIAlertController(title: "Error Signing Up", message: "Please try again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil);
                }
            }
        }
        
        
    
    }
    
    
    


}
