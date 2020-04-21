//
//  confirmUserViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/21/20.
//  Copyright © 2020 EZ Pantry. All rights reserved.
//

import UIKit
var userAdminIsCheckingAsUID = ""
class confirmUserViewController: UIViewController {

    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var popOverView: UIView!
    var userName = ""
    var userUID = ""//the UID which will be the one through which the admin checksout
    @IBOutlet weak var confirmLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        popOverView.layer.cornerRadius = 15
        popOverView.clipsToBounds = true

        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
        
        yesButton.titleLabel?.minimumScaleFactor = 0.5
        yesButton.titleLabel?.numberOfLines = 1;
        yesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        noButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true
        
        noButton.titleLabel?.minimumScaleFactor = 0.5
        noButton.titleLabel?.numberOfLines = 1;
        noButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        confirmLbl.text = "Would you like to checkout as \(userName)?"
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        userAdminIsCheckingAsUID = userUID;//admin has selected that user-save UID
        print("below")
        print(userAdminIsCheckingAsUID)
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
