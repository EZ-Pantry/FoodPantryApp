//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
class settingsPageViewController: UIViewController {

    @IBOutlet weak var sendFeedBackButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOutButton.layer.cornerRadius = 10
        logOutButton.clipsToBounds = true
        
        sendFeedBackButton.layer.cornerRadius = 15
        sendFeedBackButton.clipsToBounds = true
        
        //Below makes the button text fit the width of all constraints on any device        //https://stackoverflow.com/questions/32561435/adjust-font-size-of-text-to-fit-in-uibutton
        logOutButton.titleLabel?.minimumScaleFactor = 0.5
        logOutButton.titleLabel?.numberOfLines = 1;
        logOutButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
      sendFeedBackButton.titleLabel?.minimumScaleFactor = 0.5
        sendFeedBackButton.titleLabel?.numberOfLines = 1;
        sendFeedBackButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissBackToHome(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        //Purpose is to log out the user
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "logOut", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {


    }
    
}
