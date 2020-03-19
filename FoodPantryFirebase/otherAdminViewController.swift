//
//  otherAdminViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 3/19/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class otherAdminViewController: UIViewController {
    var ref: DatabaseReference! //reference to the firebase database
    var PantryName: String = ""
    
    @IBOutlet var checkoutSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

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
            
            self.view.isUserInteractionEnabled = true

          // ...
          }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        
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
