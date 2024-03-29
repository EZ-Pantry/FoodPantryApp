//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import WebKit
import MessageUI
import FirebaseDatabase
class contactAdminViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
        
    var emailAt = 0;
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextView!
    var subjectEntered = ""
    var messageEntered = ""
    var adminEmailAddresses = [String]()
    var activeField: UITextField!
    var ref: DatabaseReference!
    
    var PantryName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.layer.borderColor = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1.0).cgColor
        messageTextField.layer.borderWidth = 1.0;
        messageTextField.layer.cornerRadius = 5.0;
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        ref = Database.database().reference()
        sendButton.layer.cornerRadius = 15//15px
        sendButton.clipsToBounds = true
        
        sendButton.titleLabel?.minimumScaleFactor = 0.5
        sendButton.titleLabel?.numberOfLines = 1;
        sendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        getEmailsFromFirebase();
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        subjectEntered = subjectTextField.text!
        messageEntered = messageTextField.text!
        
        print(messageEntered)
        showMailComposer();
    }
    
    override func viewWillAppear(_ animated: Bool) {
             NotificationCenter.default.addObserver(self, selector: #selector(contactAdminViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                   NotificationCenter.default.addObserver(self, selector: #selector(contactAdminViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            subjectTextField.delegate = self;
            messageTextField.delegate = self;
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
    
    var tempData : [[String: Any]] = []
    func getEmailsFromFirebase(){
        self.ref.child(self.PantryName).child("Administration Contacts").observeSingleEvent(of: .value, with: { (snapshot) in
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
            
            
            
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
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
        composer.setSubject(subjectEntered.filterEmoji)//the subject line
        composer.setMessageBody(messageEntered.filterEmoji, isHTML: false)//the message
        
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
