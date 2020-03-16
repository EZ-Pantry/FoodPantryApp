//  Copyright © 2020 Ashay Parikh. All rights reserved.


import UIKit
import Foundation

class QRCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var numberTextField: UITextField! //quantity text field on the screen
    
    @IBOutlet var selectButton: UIButton! //button for selecting
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var checkoutButton: UIButton!
    
    var error = "" //error message
    
    var checkedOut = "" //format fooditem,quantity;fooditem,quantity
    var barcodes = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectButton.layer.cornerRadius = 15
        selectButton.clipsToBounds = true
        
        checkoutButton.layer.cornerRadius = 15
        checkoutButton.clipsToBounds = true
        
        numberTextField.keyboardType = UIKeyboardType.alphabet
        
        print("loaded")
    }
 
    override func viewWillAppear(_ animated: Bool) {
        
        print(checkedOut)
        print(barcodes)
        print(error)
        
        numberTextField.text = ""
        
        if error != "" { //redirected from a different view and there is an error
            errorLabel.text = error + "\nplease try again";
        } else {
             errorLabel.text = ""
        }
        
        if(checkedOut == "") {
            checkoutButton.isHidden = true
        } else {
            checkoutButton.isHidden = false
        }
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToManual"{ //person manually entered title
            let destinationVC = segue.destination as? manualViewController
            
            var title = numberTextField.text ?? ""
            title = title.filterEmoji
            
            destinationVC?.manualTitle = title
            destinationVC?.checkedOut = checkedOut
            destinationVC?.barcodes = barcodes
            checkedOut = "" //reset
            barcodes = "" //reset
            error = ""
        } else if(segue.identifier == "camera") { //person wants to scan barcode
            let destinationVC = segue.destination as? QRScannerController
            destinationVC?.checkedOut = checkedOut
            destinationVC?.barcodes = barcodes
            checkedOut = "" //reset
            barcodes = "" //reset
            error = ""
        } else if(segue.identifier == "GoToCheckout") { //person wants to scan barcode
            let destinationVC = segue.destination as? checkoutViewController
            destinationVC?.foodItems = checkedOut
            destinationVC?.barcodes = barcodes
            checkedOut = "" //reset
            barcodes = "" //reset
            error = ""
        }
    }
    
    @IBAction func unwindToQRCode(_ unwindSegue: UIStoryboardSegue) {
        
    }

    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}
