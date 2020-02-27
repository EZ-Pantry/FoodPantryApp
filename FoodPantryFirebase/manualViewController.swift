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
    
    var manualTitle = ""
    var quantity = ""
    var checkedOut = ""
    var ref: DatabaseReference!

    @IBOutlet var foodName: UILabel!
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    var foodTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.yesButton.layer.cornerRadius = 15
        self.yesButton.clipsToBounds = true
        
        self.noButton.layer.cornerRadius = 15
        self.noButton.clipsToBounds = true
        
        //check to see match
        
        self.getFoodDataFromFirebase(callback: {(data, items)-> Void in
            //compare the title the user entered to the items in the database
            
            
        })
        
        
    }
    
    func getFoodDataFromFirebase(callback: @escaping (_ data: [[String: Any]], _ names: [String])->Void) {
        self.ref = Database.database().reference()
        
        
        self.ref.child("Conant High School").child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempData : [[String: Any]] = []
            var tempNames: [String] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let name = value["Name"] as? String ?? ""
                let url = value["URL"] as? String ?? ""
                let checked = value["Checked Out"] as? String ?? ""
                let healthy = value["Healthy"] as? String ?? ""
                let quantity = value["Quantity"] as? String ?? ""
                let type = value["Type"] as? String ?? ""
                let info = value["Information"] as? String ?? ""
                let id = String(c)
                
                tempData.append(["name": name, "quantity": quantity, "amountCheckedOut": checked, "information": info, "healthy": healthy, "image": url, "id": id])
                tempNames.append(name)
                c += 1
            }
            
             callback(tempData, tempNames)
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoBack"{
            let destinationVC = segue.destination as? QRCodeViewController
            destinationVC?.error = "item not found, please try again"
            destinationVC?.checkedOut = checkedOut
        } else if(segue.identifier == "GoToScrape") {
            let destinationVC = segue.destination as? QRScrapeController
            destinationVC?.checkedOut = checkedOut
            destinationVC?.manualEnter = true
            destinationVC?.manualTitle = foodTitle
        }
    }
    
    @IBAction func selectedYes(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToScrape", sender: self)
    }
    
    @IBAction func selectedNo(_ sender: Any) {
        self.performSegue(withIdentifier: "GoBack", sender: self)
    }
}
