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

    @IBOutlet var numberTextField: UITextField!
    
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    
    var error = ""
    
    var checkedOut = "" //format fooditem,quantity;fooditem,quantity
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectButton.layer.cornerRadius = 15
        selectButton.clipsToBounds = true
        
        numberTextField.keyboardType = UIKeyboardType.alphabet
        
        if error != "" {
            errorLabel.text = error + "\nplease try again";
        }
        
        print("-----------------------")
        print(checkedOut)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToManual"{
            let destinationVC = segue.destination as? manualViewController
            destinationVC?.manualTitle = numberTextField.text!
            destinationVC?.checkedOut = checkedOut
        } else if(segue.identifier == "camera") {
            let destinationVC = segue.destination as? QRScannerController
            destinationVC?.checkedOut = checkedOut
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
