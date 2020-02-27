//
//  ViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/8/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class ViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //creating rounded edges for buttons below
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        signUpButton.layer.cornerRadius = 15;
        signUpButton.clipsToBounds = true;
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser{
            //checks if the user is already signed if
            //If so, then the user is directed directly to the home screen to prevent them from having to sign in multiple times
            self.performSegue(withIdentifier: "toHomeScreen", sender: self)
        }
    }

    
    
}



