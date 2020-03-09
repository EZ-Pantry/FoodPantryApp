//
//  adminEditPopUpViewController.swift
//  FoodPantryFirebase
//  Copyright © 2020 Ashay Parikh,
//  Rayaan Siddiqi. All rights reserved.


import UIKit

class adminEditPopUpViewController: UIViewController {

    //pop up that shows after a user selects a food in the inventory page
    @IBOutlet var popOverView: UIView!
    //labels about the food item
    @IBOutlet var foodName: UILabel!
    @IBOutlet var foodQuantity: UILabel!
    @IBOutlet var foodInformation: UILabel!
    @IBOutlet var foodCheckedout: UILabel!
    @IBOutlet var foodHealthy: UILabel!
    @IBOutlet var foodAllergy: UILabel!
    @IBOutlet var foodType: UILabel!
    
    @IBOutlet weak var editItemInfoButton: UIButton!
    @IBOutlet var foodImage: UIImageView!
    
    //data of the food item, set in another view controller
    var name = ""
    var quantity = ""
    var information = ""
    var checkedout = ""
    var healthy = ""
    var image = ""
    var allergies = ""
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets the labels on the screen
        foodName.text = name
        foodQuantity.text = "Quantity: " + String(quantity)
        foodInformation.text = "Information: " + String(information)
        foodCheckedout.text = "Checked out: " + String(checkedout)
        foodHealthy.text = "Healthy: " + String(healthy)
        
        if(image != "") {
            foodImage.load(url: URL(string: String(image))!)
        } else {
            foodImage.image = UIImage(named: "foodplaceholder.jpeg")
        }
        editItemInfoButton.layer.cornerRadius = 15
        editItemInfoButton.clipsToBounds = true
        
        
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
    
    @IBAction func editItemInfoButtonTapped(_ sender: UIButton) {
        print("hello")
        self.performSegue(withIdentifier: "toItemSpecificEdits", sender: self)
    }
    
    
    @IBAction func dismissToSearchView(_ sender: UIButton) {
        print("clicked")
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemSpecificEdits"{
            let destinationVC = segue.destination as? ediItemInfoViewController
            destinationVC?.name = (name as? String)!
            destinationVC?.quantity = (quantity as? String)!
            destinationVC?.checkedout = (checkedout as? String)!
            destinationVC?.information = (information as? String)!
            destinationVC?.healthy = (healthy as? String)!
            destinationVC?.image = (image as? String)!
            destinationVC?.type = (type as? String)!
            destinationVC?.allergies = (allergies as? String)!

        }
    }
    

    

}

