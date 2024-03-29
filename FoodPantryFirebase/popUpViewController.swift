//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit

class popUpViewController: UIViewController {

    //pop up that shows after a user selects a food in the inventory page
    @IBOutlet var popOverView: UIView!
    //labels about the food item
    @IBOutlet var foodName: UILabel!
    @IBOutlet var foodQuantity: UILabel!
    @IBOutlet var foodInformation: UILabel!
    @IBOutlet var foodHealthy: UILabel!
    @IBOutlet var foodAllergy: UILabel!
    @IBOutlet var foodType: UILabel!
    
    @IBOutlet var foodImage: UIImageView!
    
    //data of the food item, set in another view controller
    var name = ""
    var quantity = ""
    var information = ""
    var checkedout = ""
    var healthy = "1"
    var image = ""
    var allergies = "2"
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popOverView.layer.cornerRadius = 15
        popOverView.clipsToBounds = true
        
        //sets the labels on the screen
        foodName.text = name.trimTitle()
        
        print(healthy)
        print(allergies)
        
        if(Int(quantity) ?? 0 == 0) {
            foodQuantity.text = "Out of Stock"
        } else {
            foodQuantity.text = "Quantity: " + String(quantity)
        }
        foodInformation.text = "Information:\n" + String(information)
        foodHealthy.text = "Healthy:\n" + String(healthy)
        
        foodAllergy.text = "Allergies:\n" + String(allergies)
        foodType.text = "Type:\n" + String(type)

        
        if(image != "") {
            if(image.verifyUrl){
                foodImage.load(url: URL(string: String(image))!)
            }
            else{
                foodImage.image = UIImage(named: "foodplaceholder.jpeg")
            }
            
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

