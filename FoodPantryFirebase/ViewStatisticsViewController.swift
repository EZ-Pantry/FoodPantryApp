//
//  ViewStatisticsViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/26/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
class ViewStatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var totalStatsButton: UIButton!
    @IBOutlet weak var indivisualStudentButton: UIButton!
    
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var pickerField: UITextField!
    var ref: DatabaseReference!
    
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()
    
    
    var studentNames = ["Mac N Cheese", "Penne Pasta", "Granola Bars", "Veggie Soup"]
    
    var data : [[String: Any]] =  [
        ["name": "Lebron James","id": "821209", "isAdmin": "No", "totalCheckedOut": "2", "lastItemCheckedOut": "a", "LastDateCheckedOut": "no", "allergies": "grass"],
        ["name": "Cheese Grader","id": "821209", "isAdmin": "No", "totalCheckedOut": "2", "lastItemCheckedOut": "a", "LastDateCheckedOut": "no", "allergies": "grass"],
        ["name": "Kenton James","id": "821209", "isAdmin": "N", "totalCheckedOut": "2", "lastItemCheckedOut": "a", "LastDateCheckedOut": "no", "allergies": "grass"]
        
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        pickerField.inputView = yourPicker
        
        ref = Database.database().reference()
        loadStudentNames();
        totalStatsButton.layer.cornerRadius = 10
        totalStatsButton.clipsToBounds = true
        
        indivisualStudentButton.layer.cornerRadius = 10
        indivisualStudentButton.clipsToBounds = true
        
    }
    
    var userKeysArray: [String] = [String]()
    var userKeysArrayOfficial: [String] = [String]()
    @IBAction func totalStatsButtonTapped(_ sender: UIButton) {
        
    }
    @IBAction func indivisualStudentButtonTapped(_ sender: UIButton) {
        sortWhetherUser();
        
    }
    
    func sortWhetherUser(){
        print(self.data)
        print(data[0]["Admin"])
        var tempNames: [String] = []
        for i in 0..<data.count{
            print(self.data[i]["Admin"])
            if(self.data[i]["Admin"] as! String == "No"){
                print("checknboi")
                tempNames.append(self.data[i]["name"] as! String)
            }
        }
        self.studentNames = tempNames;
        print("new student names")
        print(self.studentNames)
        pickerData = self.studentNames
    }
    func loadStudentNames(){
        let userID = Auth.auth().currentUser?.uid
        self.ref.child("Conant High School").child("Users").observeSingleEvent(of: .value, with: { (snapshot) in

            var tempData : [[String: Any]] = []
            var tempNames: [String] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let name = value["Name"] as? String ?? ""
                let idNumber = value["ID Number"] as? String ?? ""
                let lastDateCheckedOut = value["Last Date Checked Out"] as? String ?? ""
                let lastItemCheckedOut = value["Last Item Checked Out"] as? String ?? ""
                let totalItemsCheckedOut = value["Total Items Checked Out"] as? String ?? ""
                let allergies = value["Allergies"] as? String ?? ""
                let adminValue = value["Admin"] as? String ?? ""
                let id = String(c)
                
                tempData.append(["name": name, "idNumber": idNumber, "lastDateCheckedOut": lastDateCheckedOut, "lastItemCheckedOut": lastItemCheckedOut, "totalItemsCheckedOut": totalItemsCheckedOut, "allergies": allergies, "Admin": adminValue, "id": id])
                tempNames.append(name)
                c += 1
            }
            
            self.data = tempData
            self.studentNames = tempNames
            
            print("data array below")
            print(self.data)
            print("studentNames below")
            print(self.studentNames)
            
        })
                
        
    }
    
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerField.text = pickerData[row]
//        studentNameLbl
        var studentNameChosen = pickerData[row];
        for i in 0..<data.count{
            if(self.data[i]["name"] as! String == studentNameChosen){
                var studentName = self.data[i]["name"]
                var studentIDNumber = self.data[i]["idNumber"]
                var lastDateCheckedOut = self.data[i]["lastDateCheckedOut"]
                var lastItemCheckedOut = self.data[i]["lastItemCheckedOut"]
                var totalItemsCheckedOut = self.data[i]["totalItemsCheckedOut"]
                var allergies = self.data[i]["allergies"]
                
                studentNameLbl.text = studentName as! String;
            }
        }
        
    }
    
    @IBAction func dismissBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
