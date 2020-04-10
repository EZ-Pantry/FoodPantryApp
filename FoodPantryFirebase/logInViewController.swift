//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.
 
 
import UIKit
import FirebaseUI
import FirebaseDatabase
import LocalAuthentication
class logInViewController: UIViewController, UITextFieldDelegate {
 
    @IBOutlet weak var emailAddressTextField: UITextField!//where user inputs their school email address
    @IBOutlet weak var passwordTextField: UITextField!//where user inputs the password
    @IBOutlet weak var continueButton: UIButton!//where user clicks to continue to home screen
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    var ref: DatabaseReference!

    var activeField : UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = Database.database().reference()

        //Create rounded buttons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        
        
        
        continueButton.titleLabel?.minimumScaleFactor = 0.5
        continueButton.titleLabel?.numberOfLines = 1;
        continueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        forgotPasswordButton.titleLabel?.minimumScaleFactor = 0.5
        forgotPasswordButton.titleLabel?.numberOfLines = 1;
        forgotPasswordButton.titleLabel?.adjustsFontSizeToFitWidth = true
 
    }
    
//    func authenticationWithTouchID() {
//        let localAuthenticationContext = LAContext()
//        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"
//
//        var authorizationError: NSError?
//        let reason = "Authentication required to access the secure data"
//
//        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
//
//            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
//
//                if success {
//                    DispatchQueue.main.async() {
//                        let alert = UIAlertController(title: "Success", message: "Authenticated succesfully!", preferredStyle: UIAlertController.Style.alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//
//                } else {
//                    // Failed to authenticate
//                    guard let error = evaluateError else {
//                        return
//                    }
//                    print(error)
//
//                }
//            }
//        } else {
//
//            guard let error = authorizationError else {
//                return
//            }
//            print(error)
//        }
//    }
//
//    func authenticateWithBiometrics(){
//        let context = LAContext()
//        var error: NSError?
//
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Identify yourself!"
//
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//                [weak self] success, authenticationError in
//
//                DispatchQueue.main.async {
//                    if success {
//                        let ac = UIAlertController(title: "Authentication Good", message: "You could  be verified; please try again.", preferredStyle: .alert)
//                        ac.addAction(UIAlertAction(title: "OK", style: .default))
//                        self!.present(ac, animated: true)
//                    } else {
//                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
//                        ac.addAction(UIAlertAction(title: "OK", style: .default))
//                        self!.present(ac, animated: true)
//                    }
//                }
//            }
//        } else {
//            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(ac, animated: true)
//        }
//    }
//
    @IBAction func handleContinue(_ sender: UIButton) {
        guard let emailaddress = emailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        print(password)
        Auth.auth().signIn(withEmail: emailaddress, password: password){ user, error in
            
            if(error != nil) {
                //else show error message
                let alert = UIAlertController(title: "Error Logging In", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            } else {
            
                    let user = Auth.auth().currentUser

                
                    if(user!.isEmailVerified) {
                            //check if admin allowed
                            let user = Auth.auth().currentUser
                            self.ref.child("All Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                            let value = snapshot.value as? NSDictionary
                             let status = value?["Account Status"] as? String ?? "" //load in the admin code
                              
                                if(status != "0") {
                                    
                                    if(status == "2") {
                                        
                                        let alert = UIAlertController(title: "Your Account has Been Suspended", message: "The admin has suspended this account.", preferredStyle: .alert)
                                                                             
                                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                                            
                                            self.performSegue(withIdentifier: "toHome", sender: self)//performs segue to the home screen to show user data with map
                                        }))
                                        self.present(alert, animated: true, completion: nil);
                                        
                                        
                                    } else {
                                        self.performSegue(withIdentifier: "toHome", sender: self)//performs segue to the home screen to show user data with map
                                    }
                                    
                                    
                                } else {
                                    let alert = UIAlertController(title: "Account Not Approved", message: "This account has not been approved by the admin", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil);
                                }
                                
                            // ...
                            }) { (error) in
                                RequestError().showError()
                                print(error.localizedDescription)
                            }
                    } else {
                        let alert = UIAlertController(title: "Email Not Verified", message: "Please check your inbox/spam folder and make sure you have verified your email!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil);
                    }
                
            
            }

        }
        
    }
    
    func checkWhetherPasswordNeedsUpdate(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(logInViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(logInViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailAddressTextField.delegate = self;
        passwordTextField.delegate = self;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
        
    func textFieldDidBeginEditing(_ textField: UITextField){
        self.activeField = textField
//        authenticationWithTouchID()
    }

//    func textFieldDidEndEditing(_ textField: UITextField){
//        activeField = nil
//    }

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
    
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {}
    
    
    
}
