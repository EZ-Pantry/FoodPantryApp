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
    
    var selectedName = ""
    var selectedUID = ""
    var selectedStatus = ""
    var selectedEmail = ""
    var selectedPassword = ""
    
    @IBOutlet var approvedTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        approvedTableView.delegate = self;
        approvedTableView.dataSource = self;
        
        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
            
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
        print("done")
    }
    
    func refresh() {
        
        users = []
        
        getPeople(callback: {(success)-> Void in //gets data from firebase
            if(success) { //same as the code in the viewDidLoad()
                
                
                let myGroup = DispatchGroup()
                print("getting status")
                
                
                for i in 0..<self.users.count {
                    myGroup.enter()
                    self.ref.child("All Users").child(self.users[i]["UID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                                   // Get user value
                        let value = snapshot.value as? NSDictionary
                        let status = value?["Account Status"] as? String ?? "" //loads in the code from firebase
                        self.users[i]["Status"] = status
                        myGroup.leave()
                    }) { (error) in
                        RequestError().showError()
                        print(error.localizedDescription)
                    }
                }
                
                myGroup.notify(queue: .main) {
                    self.approvedTableView.reloadData()
                }
            }
        })
    }
    
    func getStatus(callback: @escaping (_ success: Bool)->Void) {
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
    
    func getPeople(callback: @escaping (_ success: Bool)->Void) {
        ref.child(self.PantryName).child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                       // Get user value
            for child in snapshot.children { //iterates through all the food items
                let snap = child as! DataSnapshot
                let uid = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                let admin = value["Admin"] as? String ?? ""
                let firstName = value["First Name"] as? String ?? ""
                let lastName = value["Last Name"] as? String ?? ""
                let email = value["Email Address"] as? String ?? ""
                let password = value["Password"] as? String ?? ""
                
                if(admin != "Yes") {
                    self.users.append(["Name": firstName + " " + lastName, "UID": uid, "Email": email, "Password": password])
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! ApprovedUserViewCell
        
        cell.nameBtn.setTitle(users[indexPath.row]["Name"] as! String, for: .normal)
        
        let status = users[indexPath.row]["Status"] as! String //status

        if(status == "0") { //not approved - yellow
            cell.cellView.backgroundColor = UIColor(red: 250/255, green: 239/255, blue: 169/255, alpha: 1)
        } else if(status == "1") { //approved - blue
            cell.cellView.backgroundColor = UIColor(red: 133/255, green: 140/255, blue: 225/255, alpha: 1)
        } else if(status == "2") { //suspended - red
            cell.cellView.backgroundColor = UIColor(red: 255/255, green: 119/255, blue: 119/255, alpha: 255/255)
        }
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        
        cell.tapCallback = {
            self.selectedStatus = self.users[indexPath.row]["Status"] as! String
            self.selectedUID = self.users[indexPath.row]["UID"] as! String
            self.selectedName = self.users[indexPath.row]["Name"] as! String
            self.selectedEmail = self.users[indexPath.row]["Email"] as! String
            self.selectedPassword = self.users[indexPath.row]["Password"] as! String

            self.performSegue(withIdentifier: "userPopover", sender: nil)
        }
        
        return cell
        
        
    }
    
    @IBAction func unwindToManageUsers(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        refresh()
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "userPopover") {
            let destinationVC = segue.destination as? manageSelectedUserViewController
            destinationVC?.name = selectedName
            destinationVC?.status = selectedStatus
            destinationVC?.uid = selectedUID
            destinationVC?.email = selectedEmail
            destinationVC?.password = selectedPassword
        }
        
    }
    
}
