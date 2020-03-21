//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.

import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class notificationsViewController: UIViewController {
    var ref: DatabaseReference! //reference to the firebase database
    var PantryName: String = ""
        
    @IBOutlet var messageField: UITextField!
    @IBOutlet var lastNotification: UILabel!
    
    var fullName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func send(_ sender: Any) {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let current_date = dateFormatter.string(from: date)
        
        let message = fullName + " (" + current_date + "): " + messageField.text!.filterEmoji
        
        self.ref.child(self.PantryName).child("Admin Message").setValue(message);
        
        lastNotification.text = message
    }
    

    
}
