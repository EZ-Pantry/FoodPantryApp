//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import MessageUI
import StoreKit
class sendfeedbackcontrolsViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var rateAppButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailButton.layer.cornerRadius = 15
        emailButton.clipsToBounds = true
        
        rateAppButton.layer.cornerRadius = 15
        rateAppButton.clipsToBounds = true
    }
    
    
    @IBAction func dismissBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rateAppButtonTapped(_ sender: UIButton) {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
    
    
    

}
