//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class QRAddViewController: UIViewController, UITextFieldDelegate {
    
    //first screen admin sees when adding items 
    
    @IBOutlet var addManualButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var foodTitle: UITextField!
    
    var error = ""
    
    var activeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addManualButton.layer.cornerRadius = 15
        addManualButton.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(QRAddViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(QRAddViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        foodTitle.delegate = self;
        
        addManualButton.titleLabel?.minimumScaleFactor = 0.5
        addManualButton.titleLabel?.numberOfLines = 1;
        addManualButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(true)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField){
            print("switched")
            self.activeField = textField
        }

        func textFieldDidEndEditing(_ textField: UITextField){
            activeField = nil
        }

        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
    //            print("textfeld val below")
    //            print(self.activeField?.frame.origin.y)
    //            print("keyborad height")
    //            print(keyboardSize.height)
                if (self.activeField?.frame.origin.y)! >= keyboardSize.height {
                    self.view.frame.origin.y = keyboardSize.height - (self.activeField?.frame.origin.y)!
                } else {
                    self.view.frame.origin.y = 0
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 0
        }
    
    override func viewWillAppear(_ animated: Bool) {
        if error != "" {
            errorLabel.text = error
        }
        
        foodTitle.text = ""
    }
    
    @IBAction func addManually(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToManual", sender: self) //go to qr scrape controller
    }
    
    @IBAction func dismissBack(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToManual"{
            let destinationVC = segue.destination as? chooseManualViewController
            
            var title = self.foodTitle.text as! String
            title = title.filterEmoji
            
            destinationVC?.manualTitle = title
            
            error = ""
            
        } else if segue.identifier == "GoToScan"{
            let destinationVC = segue.destination as? addItemViewController
            
            error = ""
        }
    }
    
    @IBAction func unwindToQRAdd(_ unwindSegue: UIStoryboardSegue) {}
    
}
