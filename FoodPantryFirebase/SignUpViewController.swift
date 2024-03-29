//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.

import Foundation

import UIKit
import FirebaseUI
import FirebaseDatabase
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var firstNameField: UITextField!//users name
    @IBOutlet var lastNameField: UITextField!//users lastname
    @IBOutlet weak var schoolID: UITextField!//where user enters their school ID #(i.e 912111)
    @IBOutlet weak var emailTextField: UITextField!//where user enters their email address(jake@students.d211.org)
    @IBOutlet weak var passwordTextField: UITextField!//where user enters their password they want to use w/account
    @IBOutlet weak var allergiesTextField: UITextField!//where user enters any allergies they have
    
    //below are labels with error messages for each sector
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
    
    var activeField: UITextField!//determines which textfield is being edited off of
    
    lazy var functions = Functions.functions()
    
    //for healthy or not healthy
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()//data which can be selected via pickerView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded butons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        
        //Create rounded butons
        continueButton.titleLabel?.minimumScaleFactor = 0.5
        continueButton.titleLabel?.numberOfLines = 1;
        continueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //database reference
        ref = Database.database().reference()
        

        if userType == "admin" {
            informationHeader.isHidden = true
            allergiesTextField.isHidden = true
            schoolID.isHidden = true
            //specific fields are shown depending on user tyoe
        }
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        firstNameErrorLabel.isHidden = true
        lastNameErrorLabel.isHidden = true
        idErrorLabel.isHidden = true
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        //allergies are able to selected through Pickerview
        allergiesTextField.inputView = yourPicker
        pickerData = ["None", "Dairy", "Eggs", "Peanuts", "Tree Nuts", "Shellfish", "Wheat", "Soy", "Fish", "Other"]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerData.count

        
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
            return pickerData[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     
        allergiesTextField.text = pickerData[row]
 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //set up the textfield view move up functions
         NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //asign delgates
        firstNameField.delegate = self;
        lastNameField.delegate = self;
        emailTextField.delegate = self;
        passwordTextField.delegate = self;
        allergiesTextField.delegate = self;
        schoolID.delegate = self;
    }
    override func viewWillDisappear(_ animated: Bool) {
        //makessure to remove observer to avoid nil error
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
    //validation methods
    
    func isValidEmail(_ email: String) -> Bool {
        //checks if email is valid with the proper naming convention
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        //if password is greater than 8 characters, its good
        return password.count >= 8
    }
    
    
    @IBAction func handleContinue(_ sender: UIButton) {
        guard var firstName = firstNameField.text else { return }//get users name
        guard var lastName = lastNameField.text else { return }//get users name
        guard var schoolIDNumber = schoolID.text else { return }//get users ID
        guard var emailaddress = emailTextField.text else { return }//get users email
        guard var password = passwordTextField.text else { return }//get users password
        guard var allergies = allergiesTextField.text else { return }//get users allergies
        
         firstName = firstName.trimmingCharacters(in: .whitespaces)//trim the blanks (white space)
         lastName = lastName.trimmingCharacters(in: .whitespaces)
         emailaddress = emailaddress.trimmingCharacters(in: .whitespaces)
        
        var userError = false
        
        //error chekcs to make sure fields are properly filled in
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
        
        
        //error chekcs to make sure fields are properly filled in
        if (schoolIDNumber.count != 6 && schoolIDNumber.count != 9) && userType == "student" {
            idErrorLabel.isHidden = false
            userError = true
        } else {
            idErrorLabel.isHidden = true
        }
        
        if(schoolIDNumber.count == 9) {
            schoolIDNumber = schoolIDNumber.substring(from: 3);
        }
        //error chekcs to make sure fields are properly filled in
        if !isValidEmail(emailaddress) || emailaddress.containsEmoji {
            emailErrorLabel.isHidden = false
            userError = true
        } else {
            emailErrorLabel.isHidden = true
        }
        //error chekcs to make sure fields are properly filled in
        if !isValidPassword(password) || password.containsEmoji {
            passwordErrorLabel.isHidden = false
            userError = true
        } else {
            passwordErrorLabel.isHidden = true
        }
        //error chekcs to make sure fields are properly filled in
        if allergies == "" || allergies.containsEmoji {
            allergies = "None"
        }
        
        if(!userError){
            Auth.auth().createUser(withEmail: emailaddress, password: password){ user, error in
                if error == nil && user != nil {
                    if(self.userType == "admin"){
                        //If correct admin code was entered, create a new administrator account who can access the admin page
                        //set firebase nodes depending on user type
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("First Name").setValue(firstName)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Last Name").setValue(lastName)

                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        //self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Password").setValue(password)
                
                        self.ref.child(self.pantryName).child("Administration Contacts").child(firstName + " " + lastName).child("Email").setValue(emailaddress)
                        
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Admin").setValue("Yes")
                        
                        
                            self.ref.child("All Users").child(user!.user.uid).child("Pantry Name").setValue(self.pantryName);
                        
                            self.ref.child("All Users").child(user!.user.uid).child("Account Status").setValue("1")

                            UserDefaults.standard.set(self.pantryName, forKey: "Pantry Name")

                        self.sendVerificationMail();
                        
                    }
                    else if (self.userType == "student"){
                        //Else a regular student account
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("First Name").setValue(firstName)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Last Name").setValue(lastName)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("ID Number").setValue(schoolIDNumber)
                        self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Email Address").setValue(emailaddress)
                        //self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Password").setValue(password)
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
                        //send actual notification
                        self.functions.httpsCallable("sendNewUserMessage").call(["pantry": self.pantryName, "name": firstName + " " + lastName]) { (result, error) in
                          if let error = error as NSError? {
                            if error.domain == FunctionsErrorDomain {
                              let code = FunctionsErrorCode(rawValue: error.code)
                              let message = error.localizedDescription
                              let details = error.userInfo[FunctionsErrorDetailsKey]
                                print(message)
                                print(code)
                                print(details)
                            }
                          }
                            
                            InstanceID.instanceID().instanceID { (result, error) in
                              if let error = error {
                                print("Error fetching remote instance ID: \(error)")
                              } else if let result = result {
                                print("Remote instance ID token: \(result.token)")
                                self.ref.child(self.pantryName).child("Users").child(user!.user.uid).child("Token").setValue(result.token) { //save to firebase
                                  (error:Error?, ref:DatabaseReference) in
                                  if let error = error {
                                    print("Data could not be saved: \(error).")
                                  } else {
                                    self.sendVerificationMail()
                                  }
                                }
                              }
                            }
                            
    
                            
                        }
                        
                    }
                                        
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
        let user = Auth.auth().currentUser

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
                //display alert they are good to go and they can sign in
                let alert = UIAlertController(title: "Your Email is Already Verified, Continue to Login", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
           }
        
}



