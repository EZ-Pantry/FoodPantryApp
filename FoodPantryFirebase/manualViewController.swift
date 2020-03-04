//
//  manualViewController.swift
//  FoodPantryFirebase
//
//  Created by Conant High on 2/27/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase
class manualViewController: UIViewController {
    
    var manualTitle = "" //manual title that the person entered
    var quantity = "" //quantity
    var checkedOut = "" //checked out string, passed between views
    var ref: DatabaseReference! //ref to db
    
    //labels and buttons on the screen
    
    @IBOutlet var foodName: UILabel!
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    //actual title of the food item
    var foodTitle = ""
    var error = "" //error message
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        //make buttons round
        self.yesButton.layer.cornerRadius = 15
        self.yesButton.clipsToBounds = true
        
        self.noButton.layer.cornerRadius = 15
        self.noButton.clipsToBounds = true
        
        //check to see match
        
        self.getFoodDataFromFirebase(callback: {(data, items)-> Void in
            //compare the title the user entered to the items in the database
            var scores: [Int] = [] //match score, the higher it is the closer the match
            
            for item in items {
                scores.append(self.comparePhrases(p1: item, p2: self.manualTitle)) //adds in scores
            }
            
            if(scores.max() == 0) { //no item found
                self.error = "item not found, please try again"
            } else {
                
                var index: Int = scores.index(of: scores.max()!)! //get the index of the matched item
            
                self.foodTitle = items[index] //sets its title
            
                self.foodName.text = self.foodTitle //also sets to a variable
            
                for d in data {
                    if d["name"] as! String == self.foodTitle { //if the name is equal to the title
                        
                        let url = d["image"] as! String
                        
                        if(url != "") {
                            self.foodImage.load(url: URL(string: url)!) //load the image
                        } else {
                            self.foodImage.image = UIImage(named: "foodplaceholder.jpeg")
                        }
                        
                        break
                    }
                }
            }
            
        })
        
        
    }
    
    func comparePhrases(p1: String, p2: String) -> Int { //compares two food items, one the user inputted and one from the db
        //lower case
        var p1 = p1.lowercased()
        var p2 = p2.lowercased()
        
        //basic approach: split both phrases into words, see how many words match
        
        var matches: Int = 0
        
        var w1: [String] = p1.components(separatedBy:" ")
        var w2: [String] = p2.components(separatedBy:" ")
        
        for word in w1 {
            if w2.contains(word) {
                matches += 1
            }
        }
        
        return matches
        
    }
    
    //gets data from firebase
    func getFoodDataFromFirebase(callback: @escaping (_ data: [[String: Any]], _ names: [String])->Void) {
        self.ref = Database.database().reference()
        
        
        self.ref.child("Conant High School").child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            //data about the food item, and its titles
            var tempData : [[String: Any]] = []
            var tempNames: [String] = []
            var c: Int = 0 //id value
            for child in snapshot.children { //iterates through each food item
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                //gets the data
                let name = value["Name"] as? String ?? ""
                let url = value["URL"] as? String ?? ""
                let checked = value["Checked Out"] as? String ?? ""
                let healthy = value["Healthy"] as? String ?? ""
                let quantity = value["Quantity"] as? String ?? ""
                let type = value["Type"] as? String ?? ""
                let info = value["Information"] as? String ?? ""
                let id = String(c)
                //adds to the array
                tempData.append(["name": name, "quantity": quantity, "amountCheckedOut": checked, "information": info, "healthy": healthy, "image": url, "id": id])
                tempNames.append(name)
                c += 1
            }
            
             callback(tempData, tempNames) //calls callback
        })
    }
    
    //segue handler

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoBack"{
            let destinationVC = segue.destination as? QRCodeViewController
            destinationVC?.error = error
            destinationVC?.checkedOut = checkedOut
        } else if(segue.identifier == "GoToScrape") {
            let destinationVC = segue.destination as? QRScrapeController
            destinationVC?.checkedOut = checkedOut
            destinationVC?.manualEnter = true
            destinationVC?.manualTitle = foodTitle
        }
    }
    
    //selected yes, correct food item
    
    @IBAction func selectYes(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToScrape", sender: self) //go to qr scrape controller
    }
    
    
    @IBAction func selectedNo(_ sender: Any) {
        //in correct food item
        error = ""
        self.performSegue(withIdentifier: "GoBack", sender: self) //go back to codeview
    }
    
    
}
