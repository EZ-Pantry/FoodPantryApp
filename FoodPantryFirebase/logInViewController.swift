//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
class logInViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: UITextField!//where user inputs their school email address
    @IBOutlet weak var passwordTextField: UITextField!//where user inputs the password
    @IBOutlet weak var continueButton: UIButton!//where user clicks to continue to home screen
    var ref: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create rounded buttons
        continueButton.layer.cornerRadius = 15
        continueButton.clipsToBounds = true
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func handleContinue(_ sender: UIButton) {
        guard let emailaddress = emailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        print(password)
        Auth.auth().signIn(withEmail: emailaddress, password: password){ user, error in
            if error == nil && user != nil{
                
                let uid = Auth.auth().currentUser!.uid
                self.ref.child("All Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                             // Get user value
                             let value = snapshot.value as? NSDictionary
                               let pantry = value?["Pantry Code"] as? String ?? "" //loads in the code from firebase
                                //save pantry name to internal data
                            let defaults = UserDefaults.standard
                            defaults.set(pantry, forKey: "Pantry Code")
                                
                    
                             }) { (error) in
                               print(error.localizedDescription)
                           }
                      
                
            
        
                
                self.dismiss(animated: false, completion: nil)//sends user to home screen animation
                //If email & password exist, then sign in
            } else{
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
