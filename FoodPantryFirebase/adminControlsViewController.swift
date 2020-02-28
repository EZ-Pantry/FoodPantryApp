//
//  adminControlsViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/22/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class adminControlsViewController: UIViewController {

    @IBOutlet weak var addItemsButton: UIButton!
    @IBOutlet weak var viewInventoryButton: UIButton!
    @IBOutlet weak var viewStatisticsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addItemsButton.layer.cornerRadius = 15
        addItemsButton.clipsToBounds = true
        viewInventoryButton.layer.cornerRadius = 15
        viewInventoryButton.clipsToBounds = true
        viewStatisticsButton.layer.cornerRadius = 15
        viewStatisticsButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    

    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
