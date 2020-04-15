//
//  adminNotificationsViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 4/15/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
import MapKit
import UserNotifications
import Firebase

class adminNotificationsViewController: UIViewController  {
        
    var ref: DatabaseReference!
    var PantryName: String = ""

    @IBOutlet var popOverView: UIView!
    @IBOutlet var adminUpdateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        popOverView.layer.cornerRadius = 15
        popOverView.clipsToBounds = true
        
        displayAdminMessage()
    }
    
    func displayAdminMessage() {
        ref.child(self.PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.adminUpdateLabel.text = (value?["Admin Message"] as? String ?? "") //loads ithe
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //as anothe way of dismissing the view, outside the view
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if !popOverView.frame.contains(location) {
            print("Tapped outside the view")
            dismiss(animated: true, completion: nil)
        }else {
            print("Tapped inside the view")
        }
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        print("clicked")
        dismiss(animated: true, completion: nil)
    }
    
    

}
