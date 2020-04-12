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
        
        ref = Database.database().reference()

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
        
        loginButton.titleLabel?.minimumScaleFactor = 0.5
        loginButton.titleLabel?.numberOfLines = 1;
        loginButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        signupButton.titleLabel?.minimumScaleFactor = 0.5
        signupButton.titleLabel?.numberOfLines = 1;
        signupButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    
    private var authUser : User? {
           return Auth.auth().currentUser
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
        print("here")
        if let user = Auth.auth().currentUser {
            //checks if the user is already signed if
            //If so, then the user is directed directly to the home screen to prevent them from having to sign in multiple times
            if(authUser!.isEmailVerified){
                
                //check if admin allowed
                let user = Auth.auth().currentUser
                ref.child("All Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                 let status = value?["Account Status"] as? String ?? "" //load in the admin code
                    print("checking")
                    print(status)
                    if(status == "1") { //user is either approved or suspended
                        self.performSegue(withIdentifier: "toHomeScreen", sender: self)//performs segue to the home screen to show user data with map
                    } else if (status == "2") {
                        let alert = UIAlertController(title: "Your Account has Been Suspended", message: "The admin has suspended this account.", preferredStyle: .alert)
                                                             
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                            
                            self.performSegue(withIdentifier: "toHomeScreen", sender: self)//performs segue to the home screen to show user data with map
                        }))
                        self.present(alert, animated: true, completion: nil);
                    }
//                    } else if(status == "3") { //user is deleted
//                        try! Auth.auth().signOut()
//                        let alert = UIAlertController(title: "Your Account has Been Deleted", message: "The admin has deleted this account.", preferredStyle: .alert)
//
//                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
//
//                        }))
//                        self.present(alert, animated: true, completion: nil);
//                    }
                    
                // ...
                }) { (error) in
                    RequestError().showError()
                    print(error.localizedDescription)
                }
                
            } else {
                print("not verified")
            }
            
        } else {
            print("not logged in")
        }
        
        
        //checking to see if user is logged in, not, or deleted
        
//        if let user = Auth.auth().currentUser {
        
            checkUserAgainstDatabase { (notDeleted, error) in
            
                if(!notDeleted) { //deleted user
                    let alert = UIAlertController(title: "Error", message: "Your account has been deleted by the admin.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                        try! Auth.auth().signOut() //sign out
                        print("signed out")
                    }))
                    self.present(alert, animated: true, completion: nil);
                                        
                    //segue
                    
                }
            }
//        } else {
//            let alert = UIAlertController(title: "Error", message: "You are unauthorized to use this app", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
//
//            }))
//            self.present(alert, animated: true, completion: nil);
//            //segue
//        }
        
    }
    
    @IBAction func unwindToFirst(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        let identifier: String = unwindSegue.identifier ?? ""
        print(identifier)
    }
    
    
}

func checkUserAgainstDatabase(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
    print(Auth.auth().currentUser)
  guard let currentUser = Auth.auth().currentUser else { return }
  currentUser.getIDTokenForcingRefresh(true, completion:  { (idToken, error) in
    if let error = error {
      completion(false, error as NSError?)
      print(error.localizedDescription)
    } else {
      completion(true, nil)
    }
  })
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

