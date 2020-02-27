//
//  ViewStatisticsViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/26/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class ViewStatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var pickerField: UITextField!
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        pickerField.inputView = yourPicker
        
        pickerData = ["Total Student Visits", "Indivisual Student Data"]

        // Do any additional setup after loading the view.
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
        print("ouched pickerview")
//        schoolCodeTextField.isHidden = false;
        if(pickerData[row] == "Conant High School") {
            print("Conant Chosen")
//            schoolName = "Conant High School"
        }
        
    }
    
    @IBAction func dismissBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
