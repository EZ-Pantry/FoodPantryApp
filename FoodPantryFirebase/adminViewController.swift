//
//  adminViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/20/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class adminViewController: UIViewController {

    @IBOutlet weak var adminControlsButton: UIButton!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var schoolIDTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var ref: DatabaseReference!//referncing the database
    var isActuallyAdmin = false;//boolean to check if the admin controls button is visible
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded buttons
        saveButton.layer.cornerRadius = 15
        saveButton.clipsToBounds = true
        adminControlsButton.layer.cornerRadius = 15
        adminControlsButton.clipsToBounds = true
        ref = Database.database().reference()
        prepareButton();
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func adminControlsButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toAdminControls", sender: nil)
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        handleSaving();
    }
    
    func prepareButton(){
        let userID = Auth.auth().currentUser?.uid
        ref.child("Conant High School").child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value as? NSDictionary
            let adminValue = value?["Admin"] as? String ?? ""
            if(adminValue == "Yes"){
                self.adminControlsButton.isHidden = false;//that admin controls button only appears if the user entered the admin code when signing up
            }
          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func handleSaving(){
        //Purpose of function is to set the new changes in firebase under Users Node
        let userID = Auth.auth().currentUser?.uid//get logged in user
        
        guard let fullname = fullNameTextField.text else { return }
        guard let schoolIDNumber = schoolIDTextField.text else { return }
        guard let allergies = allergiesTextField.text else { return }
        
        if(fullname == ""){
            self.ref.child("Conant High School").child("Users").child(userID!).child("Name").setValue(fullname)//set new name
        }
        if(schoolIDNumber == ""){
            self.ref.child("Conant High School").child("Users").child(userID!).child("ID Number ").setValue(schoolIDNumber)//set new id #
        }
        if(allergies == ""){
            self.ref.child("Conant High School").child("Users").child(userID!).child("Allergies ").setValue(allergies)//set any new allergies in list format(i.e grass, roots, plants).
        }
        
        let alert = UIAlertController(title: "Changes Saved!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);//presents the alert for completion
    }
    
        
    
}
