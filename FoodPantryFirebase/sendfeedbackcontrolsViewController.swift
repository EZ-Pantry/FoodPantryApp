//
//  sendfeedbackcontrolsViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/3/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit
class sendfeedbackcontrolsViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailButton.layer.cornerRadius = 15
        emailButton.clipsToBounds = true
    }
    
    
    @IBAction func dismissBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rateAppButtonTapped(_ sender: UIButton) {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
    
    
    

}
