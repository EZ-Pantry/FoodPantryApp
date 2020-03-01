//
//  addItemViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 3/1/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class QRAddViewController: UIViewController {

    @IBOutlet var addManualButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    
    var error = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if error != "" {
            errorLabel.text = error
        }
        
        addManualButton.layer.cornerRadius = 15
        addManualButton.clipsToBounds = true
    }
    
    
}
