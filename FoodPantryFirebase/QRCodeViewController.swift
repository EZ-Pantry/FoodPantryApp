//  Copyright © 2020 Ashay Parikh. All rights reserved.


import UIKit
import Foundation

class QRCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var numberTextField: UITextField! //quantity text field on the screen
    
    @IBOutlet var selectButton: UIButton! //button for selecting
    @IBOutlet var errorLabel: UILabel!
    
    var error = "" //error message
    
    var checkedOut = "" //format fooditem,quantity;fooditem,quantity
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectButton.layer.cornerRadius = 15
        selectButton.clipsToBounds = true
        
        numberTextField.keyboardType = UIKeyboardType.alphabet
                
        if error != "" { //redirected from a different view and there is an error
            errorLabel.text = error + "\nplease try again";
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
            
            var title = numberTextField.text! ?? ""
            title = title.filterEmoji
            
            destinationVC?.manualTitle = title
            destinationVC?.checkedOut = checkedOut
        } else if(segue.identifier == "camera") { //person wants to scan barcode
            let destinationVC = segue.destination as? QRScannerController
            destinationVC?.checkedOut = checkedOut
        }
    }
    
    @IBAction func unwindToQRCode(_ unwindSegue: UIStoryboardSegue) {}

    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}
