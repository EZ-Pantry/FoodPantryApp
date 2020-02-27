//
//  profileViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/9/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class profileViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var schoolIDTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Creating rounded buttons
        saveButton.layer.cornerRadius = 15
        saveButton.clipsToBounds = true
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    var ref: DatabaseReference!
    
    @IBAction func saveTapped(_ sender: UIButton) {
        handleSaving();
    }
    
    func handleSaving(){
        //Purpose of function is to set the new changes in firebase under Users Node
        let userID = Auth.auth().currentUser?.uid//get logged in user
        
        guard let fullname = fullNameTextField.text else { return }
        guard let schoolIDNumber = schoolIDTextField.text else { return }
        guard let allergies = allergiesTextField.text else { return }
        
        
        self.ref.child("Conant High School").child("Users").child(userID!).child("Name").setValue(fullname)//set new name
        self.ref.child("Conant High School").child("Users").child(userID!).child("ID Number ").setValue(schoolIDNumber)//set new id #
        self.ref.child("Conant High School").child("Users").child(userID!).child("Allergies ").setValue(allergies)//set any new allergies in list format(i.e grass, roots, plants).
        
        let alert = UIAlertController(title: "Changes Saved!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
    }
    
}
