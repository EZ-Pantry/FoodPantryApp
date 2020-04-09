//
//  manageUsersViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 4/4/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase


class manageUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var PantryName: String = ""
    var ref: DatabaseReference! //reference to the firebase database
    
    var users: [[String: Any]] = []
    
    
    @IBOutlet var approvedTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        approvedTableView.delegate = self;
        approvedTableView.dataSource = self;
        
        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        getDataFromFirebase(callback: {(success)-> Void in //gets data from firebase
            if(success) { //same as the code in the viewDidLoad()
                self.approvedTableView.reloadData()
                
            }
        })
    
        
    }
    
    func getDataFromFirebase(callback: @escaping (_ success: Bool)->Void) {
        ref.child(self.PantryName).child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                       // Get user value
            for child in snapshot.children { //iterates through all the food items
                let snap = child as! DataSnapshot
                let uid = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                let admin = value["Admin"] as? String ?? ""
                let firstName = value["First Name"] as? String ?? ""
                let lastName = value["Last Name"] as? String ?? ""
                
                if(admin != "Yes") {
                    self.users.append(["Name": firstName + " " + lastName, "UID": uid])
                }
                
            }
            
            callback(true)
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! ApprovedUserViewCell
        cell.nameLabel.text = users[indexPath.row]["Name"] as! String
        return cell
        
        
    }
    
}
