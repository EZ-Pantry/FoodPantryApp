//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.
 
 
import UIKit
import FirebaseUI
import FirebaseDatabase
import UIKit
import FirebaseDatabase
import MapKit
import Firebase
import LocalAuthentication

class logInViewController: UIViewController, UITextFieldDelegate {
 
    @IBOutlet weak var useFaceIdButton: UIButton!
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
        
        if(UserDefaults.contains("Times Unlocked")){
            print("in here")
            var canUseBiometrics = UserDefaults.standard.object(forKey:"Times Unlocked") as! String
            if(canUseBiometrics == "Good"){
                useFaceIdButton.isHidden = false
            }
            else{
                useFaceIdButton.isHidden = true
            }
        }
        
 
    }
    
    @IBAction func useFaceIDButtonTapped(_ sender: UIButton) {
        authenticationWithTouchID()
    }
    
    
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"

        var authorizationError: NSError?
        let reason = "Authentication required to access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {

            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in

                if success {
                    DispatchQueue.main.async() {
                        var canUseBiometrics = UserDefaults.standard.object(forKey:"Times Unlocked") as! String
                        var emailaddress = UserDefaults.standard.object(forKey:"Latest Email") as! String
                        var password = UserDefaults.standard.object(forKey:"Latest Password") as! String
                        if(canUseBiometrics == "Good"){
                            self.signInUser(email: emailaddress, password: password)
                        }
                        else{
                            print("not")
                        }
                    }

                } else {
                    // Failed to authenticate
                    guard let error = evaluateError else {
                        return
                    }
                    print(error)
                    

                }
            }
        } else {

            guard let error = authorizationError else {
                return
            }
            print(error)
        }
    }

    @IBAction func handleContinue(_ sender: UIButton) {
        guard let emailaddress = emailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        print(password)
        signInUser(email: emailaddress, password: password)
        
    }
    
    func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password){ user, error in
            
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
                              let PantryName = value?["Pantry Name"] as? String ?? ""
                                
                                if(status != "0") {
                                    
                                    //set firebase notification token
                                    
                                    InstanceID.instanceID().instanceID { (result, error) in
                                      if let error = error {
                                        print("Error fetching remote instance ID: \(error)")
                                      } else if let result = result {
                                        print("Remote instance ID token: \(result.token)")
                                        self.ref.child(PantryName).child("Users").child(user!.uid).child("Token").setValue(result.token) { //save to firebase
                                          (error:Error?, ref:DatabaseReference) in
                                          if let error = error {
                                            print("Data could not be saved: \(error).")
                                          } else {
                                            if(status == "2") {
                                                UserDefaults.standard.set("Bad", forKey: "Times Unlocked")
                                                let alert = UIAlertController(title: "Your Account has Been Suspended", message: "The admin has suspended this account.", preferredStyle: .alert)
                                                                                     
                                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                                                    
                                                    UserDefaults.standard.set("Good", forKey: "Times Unlocked")
                                                    UserDefaults.standard.set(email, forKey: "Latest Email")
                                                    UserDefaults.standard.set(password, forKey: "Latest Password")
                                                    self.performSegue(withIdentifier: "toHome", sender: self)//performs segue to the home screen to show user data with map
                                                }))
                                                self.present(alert, animated: true, completion: nil);
                                                
                                                
                                            } else {
                                                UserDefaults.standard.set("Good", forKey: "Times Unlocked")
                                                UserDefaults.standard.set(email, forKey: "Latest Email")
                                                UserDefaults.standard.set(password, forKey: "Latest Password")
                                                self.performSegue(withIdentifier: "toHome", sender: self)//performs segue to the home screen to show user data with map
                                            }
                                          }
                                        }
                                      }
                                    }
                                    
                                } else {
                                    UserDefaults.standard.set("Bad", forKey: "Times Unlocked")
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
                   
                   let first = (self.activeField?.frame.origin.y) ?? -1
                   
                   if(first != -1) {
                       if (self.activeField?.frame.origin.y)! >= keyboardSize.height {
                           self.view.frame.origin.y = keyboardSize.height - (self.activeField?.frame.origin.y)!
                       } else {
                           self.view.frame.origin.y = 0
                       }
                   }
                   
               }
           }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {}
    
    
    
}
