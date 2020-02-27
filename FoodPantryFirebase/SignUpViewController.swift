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
class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var schoolID: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    
    @IBOutlet weak var schoolCodeTextField: UITextField!
    
    @IBOutlet weak var adminCodeTextField: UITextField!
    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!
    
    @IBOutlet weak var pickerField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!

    
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()
    
    var ref: DatabaseReference!

    var schoolName: String = ""
    
    var correctSchoolCodeEntered = false;
    var isAdmin = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded butons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        studentButton.layer.cornerRadius = 5
        studentButton.clipsToBounds = true
        adminButton.layer.cornerRadius = 5
        adminButton.clipsToBounds = true
        ref = Database.database().reference()
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        pickerField.inputView = yourPicker
        
        pickerData = ["Conant High School", "Hoffman Estates High School"]//All schools to choose from
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       pickerField.text = pickerData[row]
        schoolCodeTextField.isHidden = false;
        if(pickerData[row] == "Conant High School") {
            print("Conant Chosen")
            schoolName = "Conant High School"
        }
        
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
        }
        
        if(adminCodeEntered == adminCode){
            isAdmin = true;
            print("correct2")
        }
        
        if(correctSchoolCodeEntered){
            Auth.auth().createUser(withEmail: emailaddress, password: password){ user, error in
                if error == nil && user != nil{
                    print("User Created")
                    if(self.isAdmin){
                        //If correct admin code was entered, create a new administrator account who can access the admin page
                    self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Name").setValue(fullname)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("ID Number ").setValue(schoolIDNumber)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Password ").setValue(password)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Allergies ").setValue(allergies)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Admin ").setValue("Yes")
                        
                    }
                    else{
                        //Else a regular student account
                    self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Name").setValue(fullname)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("ID Number ").setValue(schoolIDNumber)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Password ").setValue(password)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Allergies ").setValue(allergies)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Admin ").setValue("No")
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Total Item's Checked Out ").setValue("0")
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Last Item Checked Out").setValue(" ")
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Last Date Visited").setValue(" ")
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
