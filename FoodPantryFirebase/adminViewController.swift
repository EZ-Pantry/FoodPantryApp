//
//  adminViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/20/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class adminViewController: UIViewController {

    @IBOutlet weak var adminCodeTxtField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    var ref: DatabaseReference!
    var isActuallyAdmin = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded buttons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        guard let adminCodeEntered = adminCodeTxtField.text else { return }
        
        let userID = Auth.auth().currentUser?.uid
            ref.child("Conant High School").child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
                let value = snapshot.value as? NSDictionary
                let adminValue = value?["Admin"] as? String ?? ""
                print("admin value \(adminValue)")
                if(adminValue == "Yes"){
                    self.isActuallyAdmin = true;
                }
                if(self.isActuallyAdmin){
                    if(adminCodeEntered == "SXY106"){
                        //If correct code entered, then go to admin page
                        self.performSegue(withIdentifier: "toAdminControls", sender: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Incorrect Credentials", message: "Please try again!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil);//presents that alert
                    }
                }
                else{
                    let alert = UIAlertController(title: "Denied Entry", message: "It seems like you don't have an Administrator Account. This page is only for admins!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil);
                }
              // ...
              }) { (error) in
                print(error.localizedDescription)
            }
        
        
        
    }
    
        
    
}
