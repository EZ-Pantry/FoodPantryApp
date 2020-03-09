//
//  inquireAboutFoodPantryViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/9/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import WebKit
class inquireAboutFoodPantryViewController: UIViewController {

    //purpose is for schools which dont have this app to contact us
    //so that we can set up the firebase and everything else for them
    //Pricing?
    

    @IBOutlet weak var webView: WKWebView!
    
    var messageEntered = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://docs.google.com/forms/d/e/1FAIpQLScLLCxQjvkaNqhUhVR9LdPVcaAbx44D65TG4o-He9BoeJFZIQ/viewform?usp=sf_link")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

    }

    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
