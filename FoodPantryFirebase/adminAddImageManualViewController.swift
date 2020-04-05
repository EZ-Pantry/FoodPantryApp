//
//  adminAddImageManualViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/2/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import WebKit
var newImageURL = ""

class adminAddImageManualViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageURLTextField: UITextField!
    var activeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.layer.cornerRadius = 15//15px
        doneButton.clipsToBounds = true
        
        doneButton.titleLabel?.minimumScaleFactor = 0.5
        doneButton.titleLabel?.numberOfLines = 1;
        doneButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
//        NotificationCenter.default.addObserver(self, selector: #selector(adminAddImageManualViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(adminAddImageManualViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        imageURLTextField.delegate = self;
        
        let url = URL(string: "https://www.google.com/imghp?sxsrf=ALeKk03e4lZxlLt96JTR0omP0WzA3y6esg:1585862815779&source=lnms&tbm=isch&sa=X&ved=2ahUKEwj1yq-u18roAhWAAp0JHW3UCGAQ_AUoAnoECBUQBA&biw=1440&bih=757")!
        webView.load(URLRequest(url: url))
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let imageURLPasted = imageURLTextField.text else { return }
        newImageURL = imageURLPasted;
        dismiss(animated: true, completion: nil)
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField){
//        print("switched")
//        self.activeField = textField
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField){
//        activeField = nil
//    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if (self.activeField?.frame.origin.y)! >= keyboardSize.height {
//                self.view.frame.origin.y = keyboardSize.height - (self.activeField?.frame.origin.y)!
//            } else {
//                self.view.frame.origin.y = 0
//            }
//        }
//    }

//    @objc func keyboardWillHide(notification: NSNotification) {
//        self.view.frame.origin.y = 0
//    }
    
}
