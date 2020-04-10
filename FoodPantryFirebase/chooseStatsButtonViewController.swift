//
//  chooseStatsButtonViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/10/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class chooseStatsButtonViewController: UIViewController {

    @IBOutlet weak var studentStatsButton: UIButton!
    @IBOutlet weak var foodPantryStatsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        doButtonConstraints()
        // Do any additional setup after loading the view.
    }
    
    func doButtonConstraints(){
        studentStatsButton.layer.cornerRadius = 15//15px
        studentStatsButton.clipsToBounds = true
        
        studentStatsButton.titleLabel?.minimumScaleFactor = 0.5
        studentStatsButton.titleLabel?.numberOfLines = 1;
        studentStatsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        foodPantryStatsButton.layer.cornerRadius = 15//15px
        foodPantryStatsButton.clipsToBounds = true
        
        foodPantryStatsButton.titleLabel?.minimumScaleFactor = 0.5
        foodPantryStatsButton.titleLabel?.numberOfLines = 1;
        foodPantryStatsButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    



}
