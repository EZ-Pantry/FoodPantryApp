//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class chooseUserViewController: UIViewController, UITextFieldDelegate {

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

    var activeField: UITextField!;
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        
        

//        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        studentBtn.layer.cornerRadius = 15
        studentBtn.clipsToBounds = true
        
        studentBtn.titleLabel?.minimumScaleFactor = 0.5
        studentBtn.titleLabel?.numberOfLines = 1;
        studentBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        adminBtn.layer.cornerRadius = 15
        adminBtn.clipsToBounds = true
        
        adminBtn.titleLabel?.minimumScaleFactor = 0.5
        adminBtn.titleLabel?.numberOfLines = 1;
        adminBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        
        continueButton.titleLabel?.minimumScaleFactor = 0.5
        continueButton.titleLabel?.numberOfLines = 1;
        continueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(chooseUserViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(chooseUserViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        adminCode.delegate = self;
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    func textFieldDidBeginEditing(_ textField: UITextField){
        self.activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (self.activeField?.frame.origin.y)! >= keyboardSize.height {
                self.view.frame.origin.y = keyboardSize.height - (self.activeField?.frame.origin.y)!
            } else {
                self.view.frame.origin.y = 0
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
     
    @IBAction func choseStudent(_ sender: Any) { //user choose to be a student
        adminCode.isHidden = true
        incorrectAdminLabel.isHidden = true
        user = "student"
        
        userField.text = "You are a user"
    }
    
    @IBAction func choseAdmin(_ sender: Any) {
        adminCode.isHidden = false
    }
    
    @IBAction func changedAdminCode(_ sender: Any) {
        let userCode = adminCode.text
        
        var trimmedString = userCode!.trimmingCharacters(in: .whitespaces) //removes spaces
        
        trimmedString = trimmedString.filterEmoji
        
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

