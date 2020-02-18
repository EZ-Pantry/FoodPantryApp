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
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        signUpButton.layer.cornerRadius = 15;
        signUpButton.clipsToBounds = true;
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("hello")
//        self.ref.child("Conant High School").child("Statistics").child("Total Visits").child("1").child("Date").setValue("2/8/2020");
//        self.ref.child("Conant High School").child("Statistics").child("Total Visits").child("1").child("Items").setValue("2/8/2020");
//        self.ref.child("Conant High School").child("Inventory").child("Total Items").setValue("200");
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("1").child("Name").setValue("Granola Bars");
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("1").child("Quantity").setValue("50");
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("1").child("Calories").setValue("75");
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("1").child("Type").setValue("Snack");
//
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("2").child("Name").setValue("Macaroni and Cheese");
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("2").child("Quantity").setValue("60");
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("2").child("Calories").setValue("45");
//        self.ref.child("Conant High School").child("Inventory").child("Food Items").child("2").child("Type").setValue("Meal");
        
        if let user = Auth.auth().currentUser{
            self.performSegue(withIdentifier: "toHomeScreen", sender: self)
        }
    }

    
    
}


//extension ViewController: FUIAuthDelegate{
//    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
//
//        if error != nil{
//            return
//        }
//
//       authDataResult?.user.uid;
//
//        performSegue(withIdentifier: "goHome", sender: self)
//    }
//}

        
//        let authUI = FUIAuth.defaultAuthUI();
//
//        guard authUI != nil else{
//            return
//        }
//        authUI?.delegate = self;
//        authUI?.providers = [FUIEmailAuth()]
//
//        let authViewController = authUI!.authViewController()
//
//        present(authViewController, animated: true, completion: nil);
