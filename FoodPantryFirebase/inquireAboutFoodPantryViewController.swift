//
//  inquireAboutFoodPantryViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/9/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import WebKit
import MessageUI
class inquireAboutFoodPantryViewController: UIViewController {

    //purpose is for schools which dont have this app to contact us
    //so that we can set up the firebase and everything else for them
    //Pricing?
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var messageTextField: UITextView!
    var messageEntered = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.layer.cornerRadius = 15//15px
        sendButton.clipsToBounds = true
        
        messageTextField.layer.borderColor = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1.0).cgColor
        messageTextField.layer.borderWidth = 1.0;
        messageTextField.layer.cornerRadius = 5.0;

    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        messageEntered = messageTextField.text!
        showMailComposer();
    }
    
    func showMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            //Show alert informing the user
            return
        }
        
        let composer = MFMailComposeViewController()//mailing object created
        composer.mailComposeDelegate = self
        composer.setToRecipients(["foodpantryappdevelopers@gmail.com"])//emails where message is sent
        composer.setSubject("Inquiry About Food Pantry")//the subject line
        composer.setMessageBody(messageEntered, isHTML: false)//the message
        
        present(composer, animated: true)//presents the apple mail message
    }
    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension inquireAboutFoodPantryViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
            //cases below
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed to send")
        case .saved:
            print("Saved")
        case .sent:
            print("Email Sent")
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true)
    }
}
