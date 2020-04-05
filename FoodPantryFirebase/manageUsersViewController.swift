//
//  manageUsersViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 4/4/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase


class manageUsersViewController: UIViewController  {
    
    var PantryName: String = ""
    var ref: DatabaseReference! //reference to the firebase database

    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        
    }
    
}
