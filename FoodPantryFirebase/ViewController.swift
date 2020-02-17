//
//  ViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/8/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
class ViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        signUpButton.layer.cornerRadius = 15;
        signUpButton.clipsToBounds = true;
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
