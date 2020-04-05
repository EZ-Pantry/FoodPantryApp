//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
class resetPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    var activeField: UITextField!;
    override func viewDidLoad() {
        super.viewDidLoad()
        //creating rounded buttons below
        resetButton.layer.cornerRadius = 15
        resetButton.clipsToBounds = true
        
        resetButton.titleLabel?.minimumScaleFactor = 0.5
        resetButton.titleLabel?.numberOfLines = 1;
        resetButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
//        emailTextField.delegate = self;
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func resetPressed(_ sender: UIButton) {
        //Purpose of function is to send the reset password email to auth email
        guard let emailaddress = emailTextField.text else { return }//gets users email
        Auth.auth().sendPasswordReset(withEmail: emailaddress) { error in
            if error == nil {
                //If no error, then email for recovery with instructions is sent-manage email strucutre in firebase
                print("email successfully sent!")
                let alert = UIAlertController(title: "Password Reset Email Sent!", message: "Please check your email and follow the directions to reset your password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                //above shows alert for successfull sent of message
            }
            else{
                let alert = UIAlertController(title: "Error Occurred!", message: "Please try again!", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                //If email does not exist, then error message appears
            }
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(resetPasswordViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(resetPasswordViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailTextField.delegate = self;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
        
    func textFieldDidBeginEditing(_ textField: UITextField){
        self.activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    
    
    @IBAction func dismissBackButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
