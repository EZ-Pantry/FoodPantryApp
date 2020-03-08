//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
class ViewController: UIViewController {


    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //creating rounded edges for buttons below
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        signupButton.layer.cornerRadius = 15;
        signupButton.clipsToBounds = true;
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser{
            //checks if the user is already signed if
            //If so, then the user is directed directly to the home screen to prevent them from having to sign in multiple times
            self.performSegue(withIdentifier: "toHomeScreen", sender: self)//performs segue to the home screen to show user data with map
        }
    }
    
    @IBAction func unwindToFirst(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    
}



