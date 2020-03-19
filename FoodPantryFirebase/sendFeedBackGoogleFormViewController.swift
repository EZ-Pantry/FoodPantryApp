//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import WebKit
class sendFeedBackGoogleFormViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://forms.gle/A47dN4RGKe168gsK6")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

    }

    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
