//
//  ediItemInfoViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/9/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
class ediItemInfoViewController: UIViewController {

    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemInfoTextField: UITextField!
    @IBOutlet weak var itemAllergiesTextField: UITextField!
    @IBOutlet weak var itemTypeTextField: UITextField!
    @IBOutlet weak var itemHealthyTextField: UITextField!
    
    @IBOutlet weak var itemQuantityTextField: UITextField!
    //data of the food item, set in another view controller
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var finishButton: UIButton!
    
    var name = ""
    var quantity = ""
    var information = ""
    var checkedout = ""
    var healthy = ""
    var image = ""
    var allergies = ""
    var type = ""
    
    var ref: DatabaseReference! //ref to db
    
    var itemBeingEditedID = "";//barcode number letters associated with item
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        finishButton.layer.cornerRadius = 15
        finishButton.clipsToBounds = true
        if(image != "") {
            itemImageView.load(url: URL(string: String(image))!)
        } else {
            itemImageView.image = UIImage(named: "foodplaceholder.jpeg")
        }
        
        itemNameTextField.text = name;
        itemInfoTextField.text = information;
        itemAllergiesTextField.text = allergies;
        itemTypeTextField.text = type;
        itemHealthyTextField.text = healthy;
        itemQuantityTextField.text = quantity;
        
        

    }
    
    
    
    func setFirebaseData(){
        self.ref.child("Conant High School").child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let nameOfItem = value["Name"] as? String ?? ""
                if(nameOfItem == self.name){
                    self.itemBeingEditedID = key;//get the barcode/id for the item to set it's data later
//                    self.itemBeingEditedID = "-" + self.itemBeingEditedID
                    //set all the fields which admin changed
                    guard let editedName = self.itemNameTextField.text else { return }
                    guard let editedInfo = self.itemInfoTextField.text else { return }
                    guard let editedAllergies = self.itemAllergiesTextField.text else { return }
                    guard let editedType = self.itemTypeTextField.text else { return }
                    guard let editedHealthy = self.itemHealthyTextField.text else { return }
                    guard let editedQuantity = self.itemQuantityTextField.text else { return }
                    
                    self.ref.child("Conant High School").child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Name").setValue(editedName);
                    self.ref.child("Conant High School").child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Information").setValue(editedInfo);
                    self.ref.child("Conant High School").child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Allergies").setValue(editedAllergies);
                    self.ref.child("Conant High School").child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Type").setValue(editedType);
                    self.ref.child("Conant High School").child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Healthy").setValue(editedHealthy);
                    self.ref.child("Conant High School").child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Quantity").setValue(editedQuantity);
                }
                c += 1
            }
            
        })
        
        
        
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        setFirebaseData();
        dismiss(animated: true, completion: nil)
    }
    

}
