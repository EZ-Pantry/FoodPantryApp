//
//  helpAndSupportViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/14/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class helpAndSupportViewController: UIViewController {

    @IBOutlet weak var contactAdminButton: UIButton!
    @IBOutlet weak var appFeedBackbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        contactAdminButton.layer.cornerRadius = 15//15px
        contactAdminButton.clipsToBounds = true
        
        appFeedBackbutton.layer.cornerRadius = 15//15px
        appFeedBackbutton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
