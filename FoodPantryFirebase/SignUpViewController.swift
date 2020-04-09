//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import Firebase
import FirebaseDatabase
var isAccountVerified = 0;
class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet weak var schoolID: UITextField!//where user enters their school ID #(i.e 912111)
    @IBOutlet weak var emailTextField: UITextField!//where user enters their email address(jake@students.d211.org)
    @IBOutlet weak var passwordTextField: UITextField!//where user enters their password they want to use w/account
    @IBOutlet weak var allergiesTextField: UITextField!//where user enters any allergies they have
    
    @IBOutlet var emailErrorLabel: UILabel!
    @IBOutlet var passwordErrorLabel: UILabel!
    @IBOutlet var firstNameErrorLabel: UILabel!
    @IBOutlet var lastNameErrorLabel: UILabel!
    @IBOutlet var idErrorLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!

    @IBOutlet var informationHeader: UILabel!
    var ref: DatabaseReference!

    var pantryName: String = ""//The pantry which user belongs to
    var userType = ""
    
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded butons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        
        continueButton.titleLabel?.minimumScaleFactor = 0.5
        continueButton.titleLabel?.numberOfLines = 1;
        continueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        ref = Database.database().reference()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        firstNameField.delegate = self;
        lastNameField.delegate = self;
        emailTextField.delegate = self;
        passwordTextField.delegate = self;
        allergiesTextField.delegate = self;
        schoolID.delegate = self;
        
        
        
        if userType == "admin" {
            informationHeader.isHidden = true
            allergiesTextField.isHidden = true
            schoolID.isHidden = true
        }
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        firstNameErrorLabel.isHidden = true
        lastNameErrorLabel.isHidden = true
        idErrorLabel.isHidden = true
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        activeTextField = textField;
//    }
//
//    @objc func keyboardDidShow(notification: Notification) {
//
//        let info:NSDictionary = notification.userInfo! as NSDictionary
//        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        let keyboardY = self.view.frame.size.height - keyboardSize.height
//
//        print("info below")
//        print(activeTextField.frame.origin.y)
//        let editingTextFieldY:CGFloat! = activeTextField.frame.origin.y
//
//        if self.view.frame.origin.y >= 0 {
//        //Checking if the textfield is really hidden behind the keyboard
//            if editingTextFieldY > keyboardY - activeTextField.frame.height {
//            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//                self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y - (editingTextFieldY! - (keyboardY - 60)), width: self.view.bounds.width,height: self.view.bounds.height)
//                }, completion: nil)
//            }
//        }
//
//    }
//
//    @objc func keyboardWillHide(notification: Notification) {
//        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//                self.view.frame = CGRect(x: 0, y: 0,width: self.view.bounds.width, height: self.view.bounds.height)
//            }, completion: nil)
//
//    }
    
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
    //validation methods
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
    
    
    @IBAction func handleContinue(_ sender: UIButton) {
        guard var firstName = firstNameField.text else { return }//get users name
        guard var lastName = lastNameField.text else { return }//get users name
        guard var schoolIDNumber = schoolID.text else { return }//get users ID
        guard var emailaddress = emailTextField.text else { return }//get users email
        guard var password = passwordTextField.text else { return }//get users password
        guard var allergies = allergiesTextField.text else { return }//get users allergies
        
        firstName = firstName.trimmingCharacters(in: .whitespaces)
         lastName = lastName.trimmingCharacters(in: .whitespaces)
         emailaddress = emailaddress.trimmingCharacters(in: .whitespaces)
        
        var userError = false
        
        if firstName == "" || firstName.containsEmoji {
            firstNameErrorLabel.isHidden = false
            userError = true
        } else {
            firstNameErrorLabel.isHidden = true
        }
        
        if lastName == "" || lastName.containsEmoji {
            lastNameErrorLabel.isHidden = false
            userError = true
        } else {
            lastNameErrorLabel.isHidden = true
        }
        
        
        
        if (schoolIDNumber.count != 6 && schoolIDNumber.count != 9) && userType == "student" {
            idErrorLabel.isHidden = false
            userError = true
        } else {
            idErrorLabel.isHidden = true
        }
        
        if(schoolIDNumber.count == 9) {
            schoolIDNumber = schoolIDNumber.substring(from: 3);
        }
        
        if !isValidEmail(emailaddress) || emailaddress.containsEmoji {
            emailErrorLabel.isHidden = false
            userError = true
        } else {
            emailErrorLabel.isHidden = true
        }
        
        if !isValidPassword(password) || password.containsEmoji {
            passwordErrorLabel.isHidden = false
            userError = true
        } else {
            passwordErrorLabel.isHidden = true
        }
        
        if allergies == "" || allergies.containsEmoji {
            allergies = "none"
        }
        
        if(!userError){
            Auth.auth().createUser(withEmail: emailaddress, password: password){ user, error in
                if error == nil && user != nil {
                    if(self.userType == "admin"){
                        //If correct admin code was entered, create a new administrator account who can access the admin page
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("First Name").setValue(firstName)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Last Name").setValue(lastName)

                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Password").setValue(password)
                
                        self.ref.child(self.pantryName).child("Administration Contacts").child(firstName + " " + lastName).child("Email").setValue(emailaddress)
                        
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Admin").setValue("Yes")
                        
                        
                            self.ref.child("All Users").child(user!.user.uid).child("Pantry Name").setValue(self.pantryName);
                        
                            self.ref.child("All Users").child(user!.user.uid).child("Account Status").setValue("1")

                            UserDefaults.standard.set(self.pantryName, forKey: "Pantry Name")

                    }
                    else if (self.userType == "student"){
                        //Else a regular student account
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("First Name").setValue(firstName)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Last Name").setValue(lastName)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("ID Number").setValue(schoolIDNumber)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Password").setValue(password)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Allergies").setValue(allergies)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Admin").setValue("No")
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Total Item's Checked Out").setValue("0")
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Last Item Checked Out").setValue(" ")
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Last Date Visited").setValue(" ")
                        
                        //0 = Not Confirmed
                        //1 = Confirmed
                        //2 = Suspended
                        //3 = Deleted

                            self.ref.child("All Users").child(user!.user.uid).child("Account Status").setValue("0")
                        
                        self.ref.child("All Users").child(user!.user.uid).child("Pantry Name").setValue(self.pantryName);
                        
                            UserDefaults.standard.set(self.pantryName, forKey: "Pantry Name")//set the pantry name so we can use this later
                        
                    }
                    
                    print("sending")
                    
                    self.sendVerificationMail();
                }  else{
                    let firebaseError = error!.localizedDescription
                    let alert = UIAlertController(title: "Error Signing Up", message: firebaseError, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil);
                }
            }
        }
        
        
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              if segue.identifier == "toHome"{
                   let destinationVC = segue.destination as? homeViewController
               }

           }
    
    @IBAction func dismissToLoginScreen(_ sender: UIButton) {
        //user is sent back to sign up or login
        dismiss(animated: true, completion: nil)
    }
    
    
    private var authUser : User? {
           return Auth.auth().currentUser
    }
    
   
    public func sendVerificationMail() {
        Auth.auth().addStateDidChangeListener { auth, user in //this makes sure that the change is processed
            if(!user!.isEmailVerified) {
                user!.sendEmailVerification(completion: { (error) in
                    print("sent verification")
                    if(error == nil) {
                        // Notify the user that the mail has sent or couldn't because of an error.
                           let alert = UIAlertController(title: "Sign Up Successful!", message: "Please verify your email and get approved by the admin!", preferredStyle: .alert)
                                                    
                           alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                                self.performSegue(withIdentifier: "signedUp", sender: self)//perform when okay tapped
                           }))
                           self.present(alert, animated: true, completion: nil);
                    } else {
                        // the user is not available-error display
                        let alert = UIAlertController(title: "Error Signing Up", message: "Please try again!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil);
                    }
                    
                
                })
            } else {
                let alert = UIAlertController(title: "Your Email is Already Verified, Continue to Login", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
           }
        
       }
}



