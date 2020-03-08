//
//  chooseSchoolViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 3/7/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class chooseSchoolViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //choose the school/food pantry
    
    @IBOutlet var pantryPicker: UITextField!
    @IBOutlet var pantryField: UITextField!
    @IBOutlet var continueButton: UIButton!
    
    @IBOutlet var errorLabel: UILabel!
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()//data which can be selected via pickerView
    
    var chosenPantry = false
    var correctPantryCode = ""
    var pantryName = ""
    
    var ref: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        pantryPicker.inputView = yourPicker
        pickerData = ["Conant High School"]//All schools to choose from array
        
        errorLabel.isHidden = true
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
        pantryField.isHidden = false
          pantryPicker.text = pickerData[row]
            self.pantryName = pickerData[row]
        ref.child(self.pantryName).observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
              let value = snapshot.value as? NSDictionary
                self.correctPantryCode = value?["Pantry Code"] as? String ?? "" //loads in the code from firebase
                self.chosenPantry = true
              }) { (error) in
                print(error.localizedDescription)
            }
       }
    
    @IBAction func userContinue(_ sender: Any) {
        
        let userCode: String = pantryField.text!
        
        let trimmedString = userCode.trimmingCharacters(in: .whitespaces) //removes spaces

        if chosenPantry && trimmedString == correctPantryCode { //pantry code matches the code entered by the user
            errorLabel.isHidden = true
            self.performSegue(withIdentifier: "GoToUser", sender: self)
        } else {
            errorLabel.isHidden = false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "GoToUser") {
            let destinationVC = segue.destination as? chooseUserViewController
            destinationVC?.pantryName = pantryName //send the code
        }
    }
    
    
    

}