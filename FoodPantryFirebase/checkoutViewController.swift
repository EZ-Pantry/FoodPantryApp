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

    @IBOutlet var fooditemLabel: UILabel!
    @IBOutlet var finishButton: UIButton!
    
    var foodItems = ""
    
    var items: [String] = []
    var quantities: [Int] = []
    
    var ref: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //update with today's date
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "d-M-yyyy"
        self.fullyFormatedDate = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        var text = ""
        var str: String = self.foodItems
        
        while str.count > 0 {
            let food = str.substring(to: str.indexDistance(of: "$")!)
            items.append(food)
            str = str.substring(from: str.indexDistance(of: "$")! + 1)
            let quantity = str.substring(to: str.indexDistance(of: ";")!)
            quantities.append(Int(quantity) ?? 0)
            text += "Item: " + food + "\nQuantity: " + quantity + "\n\n"
            str = str.substring(from: str.indexDistance(of: ";")! + 1)
        }
        
        print("done adding")
        print(items)
        print(quantities)
        
        self.fooditemLabel.text = text
        self.finishButton.layer.cornerRadius = 15
        self.finishButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    

    @IBAction func finish(_ sender: Any) {
        //update firebase database
       self.getFoodDataFromFirebase(callback: {(data)-> Void in
            print("recieved data")
            print(data)
        
        var keyList: [[String: Any]] = []
        
            for i in 0..<self.items.count {
                var key: String = self.getIdFromTitle(title: self.items[i], data: data)
                keyList.append(["key": key, "quantity": self.quantities[i]])
            }
        
            print("got keys")
            print(keyList)
        
            self.updateFirebase(keyList: keyList, callback: {() -> Void in
                print("done changing")
                self.performSegue(withIdentifier: "menu", sender: self)
            })
        })
}
    
    var fullyFormatedDate : String = ""
    func updateFirebase(keyList : [[String: Any]], callback: @escaping () -> Void) {
        print("now changing data")
        
        let myGroup = DispatchGroup()
        
        for value in keyList {
            
            myGroup.enter() //https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing
            
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
                
                
                //OTHER FIREBASE UPDATES BELOW
            
                
                print("changed " + String(quantityChanged) + " " + (key!))
              // ...
              }) { (error) in
                print(error.localizedDescription)
            }
            let userID = Auth.auth().currentUser?.uid
            self.ref.child("Conant High School").child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
                let value = snapshot.value as? NSDictionary
                //UPDATE Statistics Node
                
                //update that the student has checked out quantity number more items
                
                var totalItemsStudentHasCheckedOut = Int(value?["Total Item's Checked Out"] as? String ?? "") ?? 0
                print("total student has: ")
                print(totalItemsStudentHasCheckedOut)
                totalItemsStudentHasCheckedOut += quantityChanged;//number of items checked out would go here
                self.ref.child("Conant High School").child("Users").child(userID!).child("Total Item's Checked Out").setValue(String(totalItemsStudentHasCheckedOut))
                
                
                
                self.ref.child("Conant High School").child("Users").child(userID!).child("Last Date Visited").setValue(self.fullyFormatedDate)
                
                self.ref.child("Conant High School").child("Users").child(userID!).child("Last Item Checked Out").setValue(self.items[self.items.count-1])
                
                
                print("changed " + String(quantityChanged) + " " + (key!))
              // ...
              }) { (error) in
                print(error.localizedDescription)
            }
            
            //update statistics node with data below
            print("formatted date below")
            print(self.fullyFormatedDate)

            
            
            self.ref.child("Conant High School").child("Statistics").child("Total Visits").observeSingleEvent(of: .value, with: { (snapshot) in
                
                var dateNodesArray: [String] = [String]()
                var c: Int = 0
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let key = snap.key as String
                    dateNodesArray.append(key)
                    c += 1
                    //retrieving the keys from total visits
                }
                var dateNodeHasBeenFound = false;
                
                for i in 0..<dateNodesArray.count{
                    if(dateNodesArray[i] == self.fullyFormatedDate){
                        dateNodeHasBeenFound = true;
                    }
                }
                
                if(!dateNodeHasBeenFound){
                    print("new node created")
                    //Create a new node for that day
                    self.ref.child("Conant High School").child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Items").setValue(String(quantityChanged));
                    self.ref.child("Conant High School").child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Students Visited").setValue(String(1));
                }
                else{
                    //Update the created stats node for that day
                    print("node already created")
                    print("date below")
                    print(self.fullyFormatedDate)
                    self.ref.child("Conant High School").child("Statistics").child("Total Visits").child(self.fullyFormatedDate).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        var itemsCheckedOutThatDay = Int(value?["Items"] as? String ?? "") ?? 0
                        var studentsVisitedThatDay = Int(value?["Students Visited"] as? String ?? "") ?? 0
                        print("items checked out that day  \(itemsCheckedOutThatDay)")
                        print("visited that day \(studentsVisitedThatDay)")
                        itemsCheckedOutThatDay += quantityChanged;//number of items checked out would go here
                        studentsVisitedThatDay+=1;
                        self.ref.child("Conant High School").child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Items").setValue(String(itemsCheckedOutThatDay));
                        self.ref.child("Conant High School").child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Students Visited").setValue(String(studentsVisitedThatDay));
                    })
                    
                    
                    
                }

                print("changed " + String(quantityChanged) + " " + (key!))
                myGroup.leave()
              // ...
              }) { (error) in
                print(error.localizedDescription)
            }
            
            
            
            
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests.")
            callback()
        }
        
    }
    
    func getIdFromTitle(title: String, data: [[String: Any]]) -> String {
        
        for i in 0..<data.count {
            if ((data[i]["name"] as? String) == title) {
                return data[i]["key"] as! String
            }
        }
        
        return ""
        
    }
    
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
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

           if segue.identifier == "menu"{
                let destinationVC = segue.destination as? homeViewController
            }

        }
               
               
}
    

