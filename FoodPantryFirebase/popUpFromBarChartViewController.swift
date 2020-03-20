//
//  popUpFromBarChartViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/19/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class popUpFromBarChartViewController: UIViewController {

    //pop up that shows after a user selects a food in the inventory page
    @IBOutlet var popOverView: UIView!
    //labels about the food item
    @IBOutlet var foodName: UILabel!
    
    @IBOutlet weak var foodTotalCheckedOut: UILabel!
    @IBOutlet var foodImage: UIImageView!
    
    //data of the food item, set in another view controller
    var name = ""
    var checkedout = ""
    var image = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        popOverView.layer.cornerRadius = 15
        popOverView.clipsToBounds = true
        //sets the labels on the screen
        foodName.text = name
        foodTotalCheckedOut.text = "Total Checked Out: \(checkedout)"
        
        
        if(image != "") {
            foodImage.load(url: URL(string: String(image))!)
        } else {
            foodImage.image = UIImage(named: "foodplaceholder.jpeg")
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
        print("clicked")
        dismiss(animated: true, completion: nil)
    }

}
