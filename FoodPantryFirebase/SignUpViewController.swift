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

    @IBOutlet weak var fullNameTextField: UITextField!//where user enters their full name(i.e John Smith)
    @IBOutlet weak var schoolID: UITextField!//where user enters their school ID #(i.e 912111)
    @IBOutlet weak var emailTextField: UITextField!//where user enters their email address(jake@students.d211.org)
    @IBOutlet weak var passwordTextField: UITextField!//where user enters their password they want to use w/account
    @IBOutlet weak var allergiesTextField: UITextField!//where user enters any allergies they have
    
    @IBOutlet weak var schoolCodeTextField: UITextField!//where user enters the school code they have been provided by Food Pantry
    
    @IBOutlet weak var adminCodeTextField: UITextField!//where admin enters their admin code to validate they have an admin aaccount
    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!//where admin clicks to enter the code
    
    @IBOutlet weak var pickerField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!

    
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()//data which can be selected via pickerView
    
    var ref: DatabaseReference!

    var schoolName: String = ""//The school name which user belongs to
    
    var correctSchoolCodeEntered = false;
    var isAdmin = false;
    
    //codes
    var schoolCode: String = ""
    var adminCode: String = ""
    
    
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
        
        pickerData = ["Conant High School"]//All schools to choose from array
        
        print("here taking snapshot")
        
        ref.child("Conant High School").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
            print(value)
        self.adminCode = value?["Admin Code"] as? String ?? ""
        self.schoolCode = value?["School Code"] as? String ?? ""
            
          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        

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
    
    
    @IBAction func handleContinue(_ sender: UIButton) {
        guard let fullname = fullNameTextField.text else { return }//get users name
        guard let schoolIDNumber = schoolID.text else { return }//get users ID
        guard let emailaddress = emailTextField.text else { return }//get users email
        guard let password = passwordTextField.text else { return }//get users password
        guard let allergies = allergiesTextField.text else { return }//get users allergies
        guard let schoolCodeEntered = schoolCodeTextField.text else { return }//get users school code
        guard let adminCodeEntered = adminCodeTextField.text else { return }//get admins code
        
        if(schoolName == "Conant High School"){
            if(schoolCodeEntered == schoolCode){
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
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("ID Number").setValue(schoolIDNumber)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Password").setValue(password)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Allergies").setValue(allergies)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Admin").setValue("Yes")
                        
                    }
                    else{
                        //Else a regular student account
                    self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Name").setValue(fullname)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("ID Number").setValue(schoolIDNumber)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Password").setValue(password)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Allergies").setValue(allergies)
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Admin").setValue("No")
                        self.ref.child(self.schoolName).child("Users").child(user!.user.uid).child("Total Item's Checked Out").setValue("0")
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
    
    
    
    @IBAction func dismissToLoginScreen(_ sender: UIButton) {
        //user is sent back to sign up or login
        dismiss(animated: true, completion: nil)
    }
    
    
    


}
