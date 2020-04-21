//
//  adminSelectUserViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/21/20.
//  Copyright © 2020 EZ Pantry. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class adminSelectUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var PantryName: String = ""
    var ref: DatabaseReference! //reference to the firebase database
    
    var users: [[String: Any]] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    var usersApproved: [[String: Any]] = []
    var usersApprovedNames = [String]()
    
    var searchedUser = [String]()
    var searching = false
    
    var selectedUserUID = ""
    var selectedName = ""
    var selectedSchoolID = ""
    var selectedEmail = ""
    var lastDateVisited = ""
    var lastItemCheckedOut = ""
    var totalItemsCheckedOut = ""
    
    @IBOutlet weak var studentsTableView: UITableView!
    override func viewDidLoad() {
            
            super.viewDidLoad()
     
            studentsTableView.delegate = self;
            studentsTableView.dataSource = self;
            searchBar.delegate = self;
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
                            print("status below")
                            print(status)
                            if(status == "1" || status == "2"){
                                self.usersApproved.append(self.users[i])
                                self.usersApprovedNames.append(self.users[i]["Name"] as! String)
                            }
                            myGroup.leave()
                        }) { (error) in
                            RequestError().showError()
                            print(error.localizedDescription)
                        }
                    }
                    
                    myGroup.notify(queue: .main) {
                        self.studentsTableView.reloadData()
                        print(self.users)
                        print(self.usersApproved)
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
                    let lastDateVisit = value["Last Date Visited"] as? String ?? ""
                    let lastItemChecked = value["Last Item Checked Out"] as? String ?? ""
                    let totalItemsChecked = value["Total Item's Checked Out"] as? String ?? ""
                    
                    if(admin != "Yes") {
                        self.users.append(["Name": firstName + " " + lastName, "Last Date Visited": lastDateVisit, "Last Item Checked Out": lastItemChecked, "Total Item's Checked Out": totalItemsChecked,  "UID": uid])
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
                    let schoolID = value["ID Number"] as? String ?? ""
                    let email = value["Email Address"] as? String ?? ""
                    let lastDateVisit = value["Last Date Visited"] as? String ?? ""
                    let lastItemChecked = value["Last Item Checked Out"] as? String ?? ""
                    let totalItemsChecked = value["Total Item's Checked Out"] as? String ?? ""
                    
                    if(admin != "Yes") {
                        self.users.append(["Name": firstName + " " + lastName, "Last Date Visited": lastDateVisit, "Last Item Checked Out": lastItemChecked, "Email": email, "Total Item's Checked Out": totalItemsChecked, "ID Number": schoolID,  "UID": uid])
                        
                    }
                    
                }
                
                callback(true)
            }) { (error) in
                RequestError().showError()
                print(error.localizedDescription)
            }
        }
        
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return usersApproved.count
            
            if searching {
                return searchedUser.count
            } else {
                return usersApprovedNames.count
            }
            
        }
        
        public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! ApprovedUserViewCell
            
            print("EACH STAT BELOW")
            print(usersApproved[indexPath.row]["Status"])
            let status = usersApproved[indexPath.row]["Status"] as! String //status
     
            if (searching){
    //            var indexCurrentlyAt =
                if(status == "1" || status == "2"){
                    cell.cellView.backgroundColor = UIColor(red: 133/255, green: 140/255, blue: 225/255, alpha: 1)
                    cell.nameBtn.setTitle(searchedUser[indexPath.row] as! String, for: .normal)
                    cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
                }
                
                
                
                cell.tapCallback = {
                    self.selectedName = self.usersApproved[indexPath.row]["Name"] as! String
                    self.selectedUserUID = self.usersApproved[indexPath.row]["UID"] as! String
     
                    self.performSegue(withIdentifier: "confirmUserPopOver", sender: nil)
                }
            }
            else{
                if(status == "1" || status == "2"){
                    cell.cellView.backgroundColor = UIColor(red: 133/255, green: 140/255, blue: 225/255, alpha: 1)
                    cell.nameBtn.setTitle(usersApproved[indexPath.row]["Name"] as! String, for: .normal)
                    cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
                }
                
                
                
                cell.tapCallback = {
                    self.selectedName = self.usersApproved[indexPath.row]["Name"] as! String
                    self.selectedUserUID = self.usersApproved[indexPath.row]["UID"] as! String
     
                    self.performSegue(withIdentifier: "confirmUserPopOver", sender: nil)
                }
            }
            
            
            return cell
            
            
            
        }
        
        @IBAction func unwindToManageUsers(_ unwindSegue: UIStoryboardSegue) {
            let sourceViewController = unwindSegue.source
            // Use data from the view controller which initiated the unwind segue
            refresh()
        }
        
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if(segue.identifier == "confirmUserPopOver") {
                let destinationVC = segue.destination as? confirmUserViewController
                destinationVC?.userName = selectedName
                destinationVC?.userUID = selectedUserUID
            }
            
        }
    


}

extension adminSelectUserViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedUser = usersApprovedNames.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        studentsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        studentsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}
