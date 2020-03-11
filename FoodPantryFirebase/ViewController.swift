//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
import Network

class ViewController: UIViewController {


    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    
    var ref: DatabaseReference!
    
    var showingAlert: Bool = false;
    var canceled: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check for connection
        
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if(!self.canceled) {
                    DispatchQueue.main.async {
                        let top: UIViewController = UIApplication.topViewController()!
                        top.dismiss(animated: false)
                        self.canceled = true;
                        self.showingAlert = false;
                    }
                }
            } else {
                
                if(!self.showingAlert) {
                     DispatchQueue.main.async {
                        print("yeet2")
                        self.showLoadingAlert();
                        self.showingAlert = true;
                        self.canceled = false;
                    }
                }
                print("No connection.")
            }

        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
                
        //creating rounded edges for buttons below
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        signupButton.layer.cornerRadius = 15;
        signupButton.clipsToBounds = true;
    }
    
    func showLoadingAlert() { //shows a loading indicator on the screen
        
        //https://stackoverflow.com/questions/6131205/how-to-find-topmost-view-controller-on-ios
        //https://medium.com/swift-india/a-complete-anatomy-of-dispatch-queue-in-swift-fa30c7628132
    //https://pinkstone.co.uk/how-to-avoid-whose-view-is-not-in-the-window-hierarchy-error-when-presenting-a-uiviewcontroller/
        let alert = UIAlertController(title: nil, message: "No internet connection, please connect...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        let top: UIViewController = UIApplication.topViewController()!

        top.present(alert, animated: true, completion: nil)
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


extension UIApplication {

    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
}

