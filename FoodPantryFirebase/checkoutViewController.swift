//
//  checkoutViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 2/25/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase
class checkoutViewController: UIViewController {
    
    
    //view for when a user is checking out
    
    //the label for the food item data
    @IBOutlet var fooditemLabel: UILabel!
    @IBOutlet var finishButton: UIButton! //finish button
    
    var foodItems = "" //food items that the user chose
    
    //items and their quantities
    var items: [String] = []
    var quantities: [Int] = []
    
    var ref: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //takes the string and formats it into cleaner text
        var text = ""
        var str: String = self.foodItems
        
        while str.count > 0 {
            //substring based on $ and ; delimiters
            let food = str.substring(to: str.indexDistance(of: "$")!)
            items.append(food)
            str = str.substring(from: str.indexDistance(of: "$")! + 1)
            let quantity = str.substring(to: str.indexDistance(of: ";")!)
            quantities.append(Int(quantity) ?? 0)
            text += "Item: " + food + "\nQuantity: " + quantity + "\n\n"
            str = str.substring(from: str.indexDistance(of: ";")! + 1)
        }
        
        //rounds buttons
        self.fooditemLabel.text = text
        self.finishButton.layer.cornerRadius = 15
        self.finishButton.clipsToBounds = true

    }
    

    @IBAction func finish(_ sender: Any) { //user selects finish
        //update firebase database
       self.getFoodDataFromFirebase(callback: {(data)-> Void in
            print("recieved data")
            print(data)
        
        var keyList: [[String: Any]] = [] //gets the keys for each individual item
        
            for i in 0..<self.items.count {
                var key: String = self.getIdFromTitle(title: self.items[i], data: data) //gets the keys of each food item based on the title
                keyList.append(["key": key, "quantity": self.quantities[i]]) //appends keys
            }
        
            self.updateFirebase(keyList: keyList, callback: {() -> Void in //done updating the keys
                self.performSegue(withIdentifier: "menu", sender: self)
            })
        })
}
    
    func updateFirebase(keyList : [[String: Any]], callback: @escaping () -> Void) { //update firebase with a list of keys and their quantities checked out
        
        let myGroup = DispatchGroup() //dispatch group, needed because the for loop is async
        
        for value in keyList {
            
            myGroup.enter() //https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing
            
            //ges the key and the quantity changed
            let key = value["key"] as? String
            let quantityChanged = value["quantity"] as! Int
            
            self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key!).observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
                let value = snapshot.value as? NSDictionary
                
                var quantity = Int(value?["Quantity"] as? String ?? "") ?? 0
                quantity -= quantityChanged;//number of items checked out would go here
                self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key!).child("Quantity").setValue(String(quantity));
                
                var checkedOut = Int(value?["Checked Out"] as? String ?? "") ?? 0
                checkedOut += quantityChanged;//number of items checked out would go here
                self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key!).child("Checked Out").setValue(String(checkedOut));
                
                myGroup.leave() //all done, can leave the group
              // ...
              }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        myGroup.notify(queue: .main) { //all loops finished, can do the call back
            print("Finished all requests.")
            callback()
        }
        
    }
    
    func getIdFromTitle(title: String, data: [[String: Any]]) -> String { //returns the key of a food item based on its name
        
        for i in 0..<data.count {
            if ((data[i]["name"] as? String) == title) {
                return data[i]["key"] as! String
            }
        }
        
        return ""
        
    }
    
    //returns data from firebase, only data about the food item and no titles
    func getFoodDataFromFirebase(callback: @escaping (_ data: [[String: Any]]) -> Void) {
        self.ref = Database.database().reference()
        
        
        self.ref.child("Conant High School").child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempData : [[String: Any]] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key as String
                let value: [String: Any] = snap.value as! [String : Any]
                let name = value["Name"] as? String ?? ""
                let quantity = value["Quantity"] as? String ?? ""
                
                tempData.append(["name": name, "quantity": quantity, "key": key])
                c += 1
            }
            
             callback(tempData)
        })
    }
    

    //segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

           if segue.identifier == "menu"{
                let destinationVC = segue.destination as? homeViewController
            }

        }
               
               
}
    

