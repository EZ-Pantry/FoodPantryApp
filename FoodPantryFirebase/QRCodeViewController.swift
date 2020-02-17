//
//  QRCodeViewController.swift
//  QRCodeReader
//
//  Created by Ashay Parikh on 2/8/20.
//  Copyright © 2020 Ashay Parikh. All rights reserved.
//

import UIKit
import Foundation

class QRCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    
    var error = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectButton.layer.cornerRadius = 15
        selectButton.clipsToBounds = true
        
        numberTextField.keyboardType = UIKeyboardType.numberPad
        quantityTextField.keyboardType = UIKeyboardType.numberPad
        
        if error != "" {
            errorLabel.text = error + "\nplease try again";
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterUPC"{
            let destinationVC = segue.destination as? QRScrapeController
            destinationVC?.barcode = numberTextField.text!
            destinationVC?.quantity = quantityTextField.text!

        }
    }
    
    //to add
    //long enough upc
    //not found, go back
    //move text field up to see
    //healthy
    //display number of products
    

    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}
