//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.

import UIKit
import MessageUI

class emailFeedbackViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var subjectTextField: UITextField!
    
    var subjectEntered = ""
    var messageEntered = ""
    
    var activeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //make buttons rounded below
        emailButton.layer.cornerRadius = 15//15px
        emailButton.clipsToBounds = true
        
        emailButton.titleLabel?.minimumScaleFactor = 0.5
        emailButton.titleLabel?.numberOfLines = 1;
        emailButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        messgeTextField.layer.borderColor = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1.0).cgColor
        messgeTextField.layer.borderWidth = 1.0;
        messgeTextField.layer.cornerRadius = 5.0;
    }
    
    @IBOutlet weak var messgeTextField: UITextView!
    
    @IBAction func sendEmailButton(_ sender: UIButton) {
        subjectEntered = subjectTextField.text!
        messageEntered = messgeTextField.text!
        showMailComposer();
    }
    
    @IBAction func dismissBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(emailFeedbackViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(emailFeedbackViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        subjectTextField.delegate = self;
        messgeTextField.delegate = self;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
        
    func textFieldDidBeginEditing(_ textField: UITextField){
        self.activeField = textField
    }


    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            let first = (self.activeField?.frame.origin.y) ?? -1
            
            if(first != -1) {
                if (self.activeField?.frame.origin.y)! >= keyboardSize.height {
                    self.view.frame.origin.y = keyboardSize.height - (self.activeField?.frame.origin.y)!
                } else {
                    self.view.frame.origin.y = 0
                }
            }
            
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    
    func showMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            //Show alert informing the user
            return
        }
        
        let composer = MFMailComposeViewController()//mailing object created
        composer.mailComposeDelegate = self
        composer.setToRecipients(["foodpantryappdevelopers@gmail.com"])//emails where message is sent
        composer.setSubject(subjectEntered.filterEmoji)//the subject line
        composer.setMessageBody(messageEntered.filterEmoji, isHTML: false)//the message
        
        present(composer, animated: true)//presents the apple mail message
    }
    
}

extension emailFeedbackViewController: MFMailComposeViewControllerDelegate {
    
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
