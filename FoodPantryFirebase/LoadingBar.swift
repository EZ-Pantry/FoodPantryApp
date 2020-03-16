//
//  LoadingBar.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 3/16/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

public class LoadingBar {
    
    var showing: Bool = false
    
    var alert: UIAlertController = UIAlertController()
    
    var top: UIViewController = UIApplication.topViewController()!
    
    func showLoadingAlert() { //shows a loading indicator on the screen
        self.alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        self.alert.view.addSubview(loadingIndicator)
        
        top = UIApplication.topViewController()!
        
        showing = true
        
        top.present(self.alert, animated: true, completion: { () in
            if (!self.showing) {
                self.top = UIApplication.topViewController()!
                self.alert.dismiss(animated: false)
            }
        })
        
    }
    
    func hideLoadingAlert() {
        
        if(showing) {
            self.top = UIApplication.topViewController()!
            alert.dismiss(animated: false)

            showing = false
            print("dismissed")
        }

    }
    
}
