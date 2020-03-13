//
//  chooseUserViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 3/7/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class chooseUserViewController: UIViewController {

    //choose the type of user
    
    //screen ui
    @IBOutlet var studentBtn: UIButton!
    @IBOutlet var adminBtn: UIButton!
    @IBOutlet var adminCode: UITextField!
    @IBOutlet var userField: UILabel!
    
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var incorrectAdminLabel: UILabel!
    
    var pantryName = "" //the name of the pantry (also firebase node name)
    var correctAdminCode = "" //the correct admin code
    var ref: DatabaseReference!
    var user = "" //type of user
    var PantryName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        studentBtn.layer.cornerRadius = 15
        studentBtn.clipsToBounds = true
        
        adminBtn.layer.cornerRadius = 15
        adminBtn.clipsToBounds = true
        
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        
        
        adminCode.isHidden = true
        incorrectAdminLabel.isHidden = true
        
        ref.child(pantryName).observeSingleEvent(of: .value, with: { (snapshot) in
           // Get user value
           let value = snapshot.value as? NSDictionary
            self.correctAdminCode = value?["Admin Code"] as? String ?? "" //load in the admin code
             
           // ...
           }) { (error) in
               RequestError().showError()
               print(error.localizedDescription)
           }
        
    }
     
    @IBAction func choseStudent(_ sender: Any) { //user choose to be a student
        adminCode.isHidden = true
        incorrectAdminLabel.isHidden = true
        user = "student"
        
        userField.text = "You are a student"
    }
    
    @IBAction func choseAdmin(_ sender: Any) {
        adminCode.isHidden = false
    }
    
    @IBAction func changedAdminCode(_ sender: Any) {
        let userCode = adminCode.text
        
        let trimmedString = userCode!.trimmingCharacters(in: .whitespaces) //removes spaces
        
        if trimmedString == correctAdminCode { //correct admin code entered
            incorrectAdminLabel.isHidden = true
            user = "admin"
            userField.text = "You are an admin"
        } else {
            user = ""
            userField.text = "You are a..."
            incorrectAdminLabel.isHidden = false
        }
        
    }
    
    @IBAction func userContinue(_ sender: Any) { //continue to signup
        if user != "" {
            self.performSegue(withIdentifier: "GoToSignup", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "GoToSignup") {
            let destinationVC = segue.destination as? SignUpViewController
            destinationVC?.pantryName = pantryName //send the code
            destinationVC?.userType = user //send the code
        }
    }
    

}

