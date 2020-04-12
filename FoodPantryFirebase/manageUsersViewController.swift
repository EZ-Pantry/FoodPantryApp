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


class manageUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate   {
    
    var PantryName: String = ""
    var ref: DatabaseReference! //reference to the firebase database
    
    var users: [[String: Any]] = []
    
    var selectedName = ""
    var selectedUID = ""
    var selectedStatus = ""
    var selectedEmail = ""
    var selectedPassword = ""
    
    @IBOutlet var approvedTableView: UITableView!
    
    //picker view
    @IBOutlet var pickerField: UITextField!
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()
    
    var displayedUsers: [[String: Any]] = []
    
    var currentFilter: String = "-1" //filter - -1 = all users, 0 = not approved, 1 = approved, 2 = suspended
    
    //searching
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        approvedTableView.delegate = self;
        approvedTableView.dataSource = self;
        
        ref = Database.database().reference()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
          
        //picker view
               
        yourPicker.delegate = self
        yourPicker.dataSource = self
        pickerField.inputView = yourPicker
               
        pickerData = ["All Users", "Not Approved", "Approved", "Suspended"] //sets the values for the picker view
        
        //search bar
        self.searchBar.delegate = self
        searchBar.returnKeyType = .done;
        searchBar.enablesReturnKeyAutomatically = false
        
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return pickerData[row]
    }
    
    //when the picker view is changed
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       pickerField.text = pickerData[row]
        
       let allowedStatus = pickerData[row]
        if(allowedStatus == "All Users") {
            currentFilter = "-1"
        } else if(allowedStatus == "Not Approved") {
            currentFilter = "0"
        } else if(allowedStatus == "Approved") {
            currentFilter = "1"
        } else if(allowedStatus == "Suspended") {
            currentFilter = "2"
        }
        
        updateUsersDisplayed(filter: currentFilter)
        self.searchBar.text = ""
        
        
    }
    
    func updateUsersDisplayed(filter: String) {
        if(filter == "-1") {
            displayedUsers = users
        } else {
            displayedUsers = []
            for user in users {
                if(user["Status"] as! String == filter) {
                    displayedUsers.append(user)
                }
            }
        }
        self.approvedTableView.reloadData()
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
                    self.updateUsersDisplayed(filter: self.currentFilter)
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
        return displayedUsers.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! ApprovedUserViewCell
        
        cell.nameBtn.setTitle(displayedUsers[indexPath.row]["Name"] as! String, for: .normal)
        
        let status = displayedUsers[indexPath.row]["Status"] as! String //status

        if(status == "0") { //not approved - grey
            cell.cellView.backgroundColor = UIColor(red: 192/255, green: 177/255, blue: 192/255, alpha: 1)
        } else if(status == "1") { //approved - orange
            cell.cellView.backgroundColor = UIColor(red: 241/255, green: 143/255, blue: 0/255, alpha: 1)
        } else if(status == "2") { //suspended - green
            cell.cellView.backgroundColor = UIColor(red: 143/255, green: 146/255, blue: 26/255, alpha: 255/255)
        }
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        
        cell.tapCallback = {
            self.selectedStatus = self.displayedUsers[indexPath.row]["Status"] as! String
            self.selectedUID = self.displayedUsers[indexPath.row]["UID"] as! String
            self.selectedName = self.displayedUsers[indexPath.row]["Name"] as! String
            self.selectedEmail = self.displayedUsers[indexPath.row]["Email"] as! String
            self.selectedPassword = self.displayedUsers[indexPath.row]["Password"] as! String

            self.performSegue(withIdentifier: "userPopover", sender: nil)
        }
        
        return cell
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "") {
            displayedUsers = users
        } else {
            displayedUsers = filterArray(dataValues: users, searchText: searchText)
        }
        approvedTableView.reloadData()
    }

    func filterArray(dataValues: [[String: Any]], searchText: String) -> ([[String: Any]]) {
        var newValues: [[String: Any]] = []
        
        var count = 0
        for val in dataValues {
            if ((val["Name"] as! String).contains(searchText)) {
                newValues.append(dataValues[count])
            }
            count += 1
        }
        return newValues
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        approvedTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
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

