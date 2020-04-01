//
//  otherTwoAdminViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/31/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class otherTwoAdminViewController: UIViewController {

    @IBOutlet weak var foodPantryInfoButton: UIButton!
    @IBOutlet weak var addFaqItemsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodPantryInfoButton.layer.cornerRadius = 15//15px
        foodPantryInfoButton.clipsToBounds = true
        
        foodPantryInfoButton.titleLabel?.minimumScaleFactor = 0.5
        foodPantryInfoButton.titleLabel?.numberOfLines = 1;
        foodPantryInfoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        addFaqItemsButton.layer.cornerRadius = 15//15px
        addFaqItemsButton.clipsToBounds = true
        
        addFaqItemsButton.titleLabel?.minimumScaleFactor = 0.5
        addFaqItemsButton.titleLabel?.numberOfLines = 1;
        addFaqItemsButton.titleLabel?.adjustsFontSizeToFitWidth = true

        // Do any additional setup after loading the view.
    }
    


}
