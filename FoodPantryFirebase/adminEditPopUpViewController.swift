//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import Foundation
import FirebaseUI
import FirebaseDatabase

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
    @IBOutlet var deleteItemButton: UIButton!
    
    //data of the food item, set in another view controller
    var name = ""
    var quantity = ""
    var information = ""
    var checkedout = ""
    var healthy = ""
    var image = ""
    var allergies = ""
    var type = ""
    var timesCheckedOut = 0
    
    var uid = ""
    
    var PantryName: String = ""
    
    var ref: DatabaseReference! //reference to the firebase database

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        ref = Database.database().reference()

        //sets the labels on the screen
        foodName.text = name.trimTitle()
        foodQuantity.text = "Quantity: " + String(quantity)
        foodInformation.text = "Information: " + String(information)
        foodCheckedout.text = "Total Checked out: " + String(checkedout)
        foodHealthy.text = "Healthy: " + String(healthy)
        foodAllergy.text = "Healthy: " + String(allergies)
        foodType.text = "Healthy: " + String(type)

        if(image != "") {
            foodImage.load(url: URL(string: String(image))!)
        } else {
            foodImage.image = UIImage(named: "foodplaceholder.jpeg")
        }
        editItemInfoButton.layer.cornerRadius = 15
        editItemInfoButton.clipsToBounds = true
        
        editItemInfoButton.titleLabel?.minimumScaleFactor = 0.5
        editItemInfoButton.titleLabel?.numberOfLines = 1;
        editItemInfoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        deleteItemButton.layer.cornerRadius = 15
        deleteItemButton.clipsToBounds = true
        
        deleteItemButton.titleLabel?.minimumScaleFactor = 0.5
        deleteItemButton.titleLabel?.numberOfLines = 1;
        deleteItemButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
    
    @IBAction func deleteItem(_ sender: Any) {
        
        let item = self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(uid)
        
        item.removeValue { error, _ in

            if(error != nil) {
                RequestError().showError()
            } else {
                self.performSegue(withIdentifier: "GoBack", sender: self)
            }
            
        }
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


