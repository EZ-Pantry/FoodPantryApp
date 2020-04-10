//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.

import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class otherAdminViewController: UIViewController, UITextFieldDelegate {
    var ref: DatabaseReference! //reference to the firebase database
    var PantryName: String = ""
    
    @IBOutlet var checkoutSwitch: UISwitch!
    @IBOutlet var adminCode: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var pantryCode: UITextField!
    @IBOutlet var location: UITextField!
    
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

       saveButton.layer.cornerRadius = 15
       saveButton.clipsToBounds = true
        
        
        saveButton.titleLabel?.minimumScaleFactor = 0.5
        saveButton.titleLabel?.numberOfLines = 1;
        saveButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
          
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(otherAdminViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otherAdminViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        adminCode.delegate = self;
        pantryCode.delegate = self;
        location.delegate = self;
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
    
    override func viewDidAppear(_ animated: Bool) {
        //check if checking out is allowed
        self.view.isUserInteractionEnabled = false
               
        ref.child(self.PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let checkout = value?["CanCheckout"] as? String ?? ""
                 
            if(checkout == "yes") {
                self.checkoutSwitch.setOn(true, animated: true)
            } else {
                self.checkoutSwitch.setOn(false, animated: true)
            }
            
            let adminCode = value?["Admin Code"] as? String ?? ""
            self.adminCode.text = adminCode
            
            let location = value?["Location"] as? String ?? ""
            self.location.text = location
            
            let pantryCode = value?["Pantry Code"] as? String ?? ""
            self.pantryCode.text = pantryCode
            
            self.view.isUserInteractionEnabled = true
            // ...
            }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        
        
    }

    
    @IBAction func saveAdminCode(_ sender: Any) {
        
        let newAdminCode = adminCode.text?.filterEmoji ?? ""
        let newPantryCode = pantryCode.text?.filterEmoji ?? ""
        let newLocation = location.text?.filterEmoji ?? ""
        
        if(newAdminCode.count >= 1) {
            self.ref.child(self.PantryName).child("Admin Code").setValue(newAdminCode);
        }
        
        if(newPantryCode.count >= 1) {
            self.ref.child(self.PantryName).child("Pantry Code").setValue(newPantryCode);
        }
        
        self.ref.child(self.PantryName).child("Location").setValue(newLocation);
        
        let alert = UIAlertController(title: "All Done", message: "The settings have been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);//presents the alert for completion
    
    }

    @IBAction func checkoutChanged(_ sender: Any) {
        
        if(checkoutSwitch.isOn) {
            self.ref.child(self.PantryName).child("CanCheckout").setValue("yes");
        } else {
            self.ref.child(self.PantryName).child("CanCheckout").setValue("no");
        }
        
    }
    
    
    @IBAction func dismissBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
