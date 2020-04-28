//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
class resetPasswordViewController: UIViewController {

    @IBOutlet weak var resetButton: UIButton!//reset button
    
    @IBOutlet var verifyButton: UIButton!//if they want to re-verify button
    var activeField: UITextField!;
    override func viewDidLoad() {
        super.viewDidLoad()
        //creating rounded buttons below
        resetButton.layer.cornerRadius = 15
        resetButton.clipsToBounds = true
        
        resetButton.titleLabel?.minimumScaleFactor = 0.5
        resetButton.titleLabel?.numberOfLines = 1;
        resetButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
//creating rounded buttons below
        verifyButton.layer.cornerRadius = 15
        verifyButton.clipsToBounds = true
        
        verifyButton.titleLabel?.minimumScaleFactor = 0.5
        verifyButton.titleLabel?.numberOfLines = 1;
        verifyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    

    

}
