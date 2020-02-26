//
//  popUpViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/20/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class popUpViewController: UIViewController {
        
    @IBOutlet var popOverView: UIView!
    
    @IBOutlet var foodName: UILabel!
    @IBOutlet var foodQuantity: UILabel!
    @IBOutlet var foodInformation: UILabel!
    @IBOutlet var foodCheckedout: UILabel!
    @IBOutlet var foodHealthy: UILabel!
    
    @IBOutlet var foodImage: UIImageView!
    var name = ""
    var quantity = ""
    var information = ""
    var checkedout = ""
    var healthy = ""
    var image = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodName.text = name
        foodQuantity.text = "Quantity: " + String(quantity)
        foodInformation.text = "Information: " + String(information)
        foodCheckedout.text = "Checked out: " + String(checkedout)
        foodHealthy.text = "Healthy: " + String(healthy)
        
        if(image != "") {
            foodImage.load(url: URL(string: String(image))!)
        }
        
        
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
    
    @IBAction func dismissToSearchView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}

