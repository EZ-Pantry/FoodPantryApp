//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import Foundation
import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

public class RequestError {
    
    public func showError() {
        let alert = UIAlertController(title: nil, message: "There is an error. Please close out of the app and restart.", preferredStyle: .alert)
        let top: UIViewController = UIApplication.topViewController()!
        top.present(alert, animated: true, completion: nil)
    }
    
}
