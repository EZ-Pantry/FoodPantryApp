//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit

class helpAndSupportViewController: UIViewController {

    @IBOutlet weak var contactAdminButton: UIButton!
    @IBOutlet weak var appFeedBackbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        contactAdminButton.layer.cornerRadius = 15//15px
        contactAdminButton.clipsToBounds = true
        
        appFeedBackbutton.layer.cornerRadius = 15//15px
        appFeedBackbutton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
