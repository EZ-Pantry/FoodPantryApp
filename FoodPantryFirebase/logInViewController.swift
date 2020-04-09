//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.
 
 
import UIKit
import FirebaseUI
import FirebaseDatabase
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(logInViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logInViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailAddressTextField.delegate = self;
        passwordTextField.delegate = self;
        continueButton.titleLabel?.minimumScaleFactor = 0.5
        continueButton.titleLabel?.numberOfLines = 1;
        continueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        forgotPasswordButton.titleLabel?.minimumScaleFactor = 0.5
        forgotPasswordButton.titleLabel?.numberOfLines = 1;
        forgotPasswordButton.titleLabel?.adjustsFontSizeToFitWidth = true
 
    }
    
 
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
            
                Auth.auth().addStateDidChangeListener { auth, user in //this makes sure that the change is processed
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
    
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {}
    
    
    
}
