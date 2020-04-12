//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
class resetPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var verifyButton: UIButton!
    var activeField: UITextField!;
    override func viewDidLoad() {
        super.viewDidLoad()
        //creating rounded buttons below
        resetButton.layer.cornerRadius = 15
        resetButton.clipsToBounds = true
        
        resetButton.titleLabel?.minimumScaleFactor = 0.5
        resetButton.titleLabel?.numberOfLines = 1;
        resetButton.titleLabel?.adjustsFontSizeToFitWidth = true
        

        verifyButton.layer.cornerRadius = 15
        verifyButton.clipsToBounds = true
        
        verifyButton.titleLabel?.minimumScaleFactor = 0.5
        verifyButton.titleLabel?.numberOfLines = 1;
        verifyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        emailTextField.delegate = self;
        
        
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
                let alert = UIAlertController(title: "Error Occurred!", message: "Please enter the correct email!", preferredStyle: .alert)//displays alert of erRor!
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
                //If email does not exist, then error message appears
            }
        } 
    }
    

    @IBAction func sendEmailNotification(_ sender: Any) {
        
        guard let emailaddress = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: emailaddress, password: password){ user, error in
            
            if(error != nil) {
                print(error)
                //else show error message
                let alert = UIAlertController(title: "Error Occured!", message: "Please enter the correct email and password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            } else {
            
                    let user = Auth.auth().currentUser
                        if(!user!.isEmailVerified) {
                        user!.sendEmailVerification(completion: { (error) in
                            print("sent verification")
                            if(error == nil) {
                                let alert = UIAlertController(title: "Email Sent", message: "The verification email has been sent. Check your inbox!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil);
                            } else {
                                print(error)
                                // the user is not available-error display
                                let alert = UIAlertController(title: "Error", message: "Please try again!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil);
                            }


                        })

                        } else {
                            let alert = UIAlertController(title: "Already Verified", message: "This account is already verified. If you cannot login, please contact the admin.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil);
                        }
                }
            
            }

        }
            
    
    @IBAction func dismissBackButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
