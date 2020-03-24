//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit

class helpAndSupportViewController: UIViewController {

    @IBOutlet weak var faqButton: UIButton!
    @IBOutlet weak var contactAdminButton: UIButton!
    @IBOutlet weak var appFeedBackbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        contactAdminButton.layer.cornerRadius = 15//15px
        contactAdminButton.clipsToBounds = true
        
        contactAdminButton.titleLabel?.minimumScaleFactor = 0.5
        contactAdminButton.titleLabel?.numberOfLines = 1;
        contactAdminButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        appFeedBackbutton.layer.cornerRadius = 15//15px
        appFeedBackbutton.clipsToBounds = true
        
        appFeedBackbutton.titleLabel?.minimumScaleFactor = 0.5
        appFeedBackbutton.titleLabel?.numberOfLines = 1;
        appFeedBackbutton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        faqButton.layer.cornerRadius = 15//15px
        faqButton.clipsToBounds = true
        
        faqButton.titleLabel?.minimumScaleFactor = 0.5
        faqButton.titleLabel?.numberOfLines = 1;
        faqButton.titleLabel?.adjustsFontSizeToFitWidth = true

        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
