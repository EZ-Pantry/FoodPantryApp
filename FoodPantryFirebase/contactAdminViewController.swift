//
//  contactAdminViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/11/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import WebKit
import MessageUI
import FirebaseDatabase
class contactAdminViewController: UIViewController {
        
    var emailAt = 0;
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    var subjectEntered = ""
    var messageEntered = ""
    var adminEmailAddresses = [String]()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        sendButton.layer.cornerRadius = 15//15px
        sendButton.clipsToBounds = true
        
        getEmailsFromFirebase();
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        subjectEntered = subjectTextField.text!
        messageEntered = messageTextField.text!
        
        showMailComposer();
    }
    
    var tempData : [[String: Any]] = []
    func getEmailsFromFirebase(){
        self.ref.child("Conant High School").child("Administration Contacts").observeSingleEvent(of: .value, with: { (snapshot) in
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let adminEmail = value["Email"] as? String ?? ""//getting students visited from firebase

                self.tempData.append(["adminName": key, "adminEmail": adminEmail])
                self.adminEmailAddresses.append(adminEmail)
                c += 1
            }
            
            
            
        })
    }
    
    @IBAction func dismissBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func showMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            //Show alert informing the user
            return
        }
        
        let composer = MFMailComposeViewController()//mailing object created
        composer.mailComposeDelegate = self as! MFMailComposeViewControllerDelegate
        composer.setToRecipients(adminEmailAddresses)//emails where message is sent
        composer.setSubject(subjectEntered)//the subject line
        composer.setMessageBody(messageEntered, isHTML: false)//the message
        
        present(composer, animated: true)//presents the apple mail message
    }


}

extension contactAdminViewController: MFMailComposeViewControllerDelegate {
    
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
