//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.

import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class notificationsViewController: UIViewController, UITextFieldDelegate {
    var ref: DatabaseReference! //reference to the firebase database
    var PantryName: String = ""
        
    @IBOutlet var messageField: UITextField!
    @IBOutlet var lastNotification: UILabel!
    
    @IBOutlet weak var validLbl: UILabel!
    var fullName = ""
    
    @IBOutlet weak var sendButton: UIButton!
    
    var activeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        messageField.delegate = self;
        
        sendButton.layer.cornerRadius = 15
        sendButton.clipsToBounds = true
        
        sendButton.titleLabel?.minimumScaleFactor = 0.5
        sendButton.titleLabel?.numberOfLines = 1;
        sendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        validLbl.isHidden = true;
        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        ref.child(self.PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.lastNotification.text = value?["Admin Message"] as? String ?? "" //loads ithe
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        
        let userID = Auth.auth().currentUser?.uid
        ref.child(PantryName).child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
          let firstName = value?["First Name"] as? String ?? ""
            let lastName = value?["Last Name"] as? String ?? ""
            self.fullName = firstName + " " + lastName
            
            //all code with snapshot must be in here
          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(true)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField){
            print("switched")
            self.activeField = textField
        }

        func textFieldDidEndEditing(_ textField: UITextField){
            activeField = nil
        }

        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
    //            print("textfeld val below")
    //            print(self.activeField?.frame.origin.y)
    //            print("keyborad height")
    //            print(keyboardSize.height)
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
    
    @IBAction func send(_ sender: Any) {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let current_date = dateFormatter.string(from: date)
        
        if(messageField.text! == ""){
            validLbl.isHidden = false;
        }
        else{
            validLbl.isHidden = true;
            let message = fullName + " (" + current_date + "): " + messageField.text!.filterEmoji
            
            self.ref.child(self.PantryName).child("Admin Message").setValue(message);
            
            lastNotification.text = message
        }
        
    }
    

    
}
