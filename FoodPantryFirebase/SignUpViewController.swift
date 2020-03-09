//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import Firebase
import FirebaseDatabase
var isAccountVerified = 0;
class SignUpViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded butons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        ref = Database.database().reference()
        
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
        guard let firstName = firstNameField.text else { return }//get users name
        guard let lastName = lastNameField.text else { return }//get users name
        guard var schoolIDNumber = schoolID.text else { return }//get users ID
        guard let emailaddress = emailTextField.text else { return }//get users email
        guard let password = passwordTextField.text else { return }//get users password
        guard var allergies = allergiesTextField.text else { return }//get users allergies
        
        
        if(schoolIDNumber.count >= 4) {
            if((schoolIDNumber.substring(with: 0..<3)) == "000"){
                //makes sure ID number is just the numbers without the zeroes
                schoolIDNumber = schoolIDNumber.substring(from: 3);
            }
        }
        
        var userError = false
        
        if firstName == "" {
            firstNameErrorLabel.isHidden = false
            userError = true
        } else {
            firstNameErrorLabel.isHidden = true
        }
        
        if lastName == "" {
            lastNameErrorLabel.isHidden = false
            userError = true
        } else {
            lastNameErrorLabel.isHidden = true
        }
        
        if schoolIDNumber.count != 6 && userType == "student" {
            idErrorLabel.isHidden = false
            userError = true
        } else {
            idErrorLabel.isHidden = true
        }
        
        if !isValidEmail(emailaddress) {
            emailErrorLabel.isHidden = false
            userError = true
        } else {
            emailErrorLabel.isHidden = true
        }
        
        if !isValidPassword(password) {
            passwordErrorLabel.isHidden = false
            userError = true
        } else {
            passwordErrorLabel.isHidden = true
        }
        
        if allergies == "" {
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
                
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Admin").setValue("Yes")
                        
                        print("added")
                        
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
                    }
                    
                    self.sendVerificationMail();
                    self.performSegue(withIdentifier: "toHome", sender: self)

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
           if self.authUser != nil && !self.authUser!.isEmailVerified {
               self.authUser!.sendEmailVerification(completion: { (error) in
                   // Notify the user that the mail has sent or couldn't because of an error.
                   let alert = UIAlertController(title: "Sign up successful", message: "Please verify your email!", preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
                   }))
                   UserDefaults.standard.set(isAccountVerified, forKey: "isAccountVerified");//action for click
               })
               
           }
           else {
               // Either the user is not available, or the user is already verified.
               let alert = UIAlertController(title: "Error Signing Up", message: "Please try again!", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
               self.present(alert, animated: true, completion: nil);
           }
       }
    
    


}
