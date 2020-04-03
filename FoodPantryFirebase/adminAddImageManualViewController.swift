//
//  adminAddImageManualViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/2/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import WebKit
var newImageURL = ""

class adminAddImageManualViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageURLTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.layer.cornerRadius = 15//15px
        doneButton.clipsToBounds = true
        
        doneButton.titleLabel?.minimumScaleFactor = 0.5
        doneButton.titleLabel?.numberOfLines = 1;
        doneButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        let url = URL(string: "https://www.google.com/imghp?sxsrf=ALeKk03e4lZxlLt96JTR0omP0WzA3y6esg:1585862815779&source=lnms&tbm=isch&sa=X&ved=2ahUKEwj1yq-u18roAhWAAp0JHW3UCGAQ_AUoAnoECBUQBA&biw=1440&bih=757")!
        webView.load(URLRequest(url: url))
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let imageURLPasted = imageURLTextField.text else { return }
        newImageURL = imageURLPasted;
        dismiss(animated: true, completion: nil)
    }
    
}
