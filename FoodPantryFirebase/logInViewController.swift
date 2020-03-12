//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.
 
 
import UIKit
import FirebaseUI
import FirebaseDatabase
class logInViewController: UIViewController {
 
    @IBOutlet weak var emailAddressTextField: UITextField!//where user inputs their school email address
    @IBOutlet weak var passwordTextField: UITextField!//where user inputs the password
    @IBOutlet weak var continueButton: UIButton!//where user clicks to continue to home screen
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded buttons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
 
        // Do any additional setup after loading the view.
    }
    
 
    @IBAction func handleContinue(_ sender: UIButton) {
        guard let emailaddress = emailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        print(password)
//        isAccountVerified = UserDefaults.standard.integer(forKey: "isAccountVerified")
        Auth.auth().signIn(withEmail: emailaddress, password: password){ user, error in
            var isValidated = user?.user.isEmailVerified;
            if error == nil && user != nil && isValidated!{
//                isAccountVerified+=1;
//                UserDefaults.standard.set(isAccountVerified, forKey: "isAccountVerified");
                self.dismiss(animated: false, completion: nil)//sends user to home screen animation
                //If email & password exist, then sign in
            }
            else if(isValidated! == false){
                let alert = UIAlertController(title: "Email Not Verified", message: "Please check your inbox/spam folder and make sure you have verified your email!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
            else{
                //else show error message
                let alert = UIAlertController(title: "Error Logging In", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil);
            }
        }
        
    }
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func dismissToLoginScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        //send back to login or signup screen
    }
    
    
}
