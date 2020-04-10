//  Copyright © 2020 Ashay Parikh. All rights reserved.


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class QRCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var numberTextField: UITextField! //quantity text field on the screen
    
    @IBOutlet var selectButton: UIButton! //button for selecting
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var checkoutButton: UIButton!
    
    var error = "" //error message
    
    var checkedOut = "" //format fooditem,quantity;fooditem,quantity
    var barcodes = ""
    
    let timeDifference: Int = 10
    
    var PantryName: String = ""
    var ref: DatabaseReference! //reference to the firebase database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        // Do any additional setup after loading the view.
        selectButton.layer.cornerRadius = 15
        selectButton.clipsToBounds = true
        
        selectButton.titleLabel?.minimumScaleFactor = 0.5
        selectButton.titleLabel?.numberOfLines = 1;
        selectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        checkoutButton.layer.cornerRadius = 15
        checkoutButton.clipsToBounds = true
        
        checkoutButton.titleLabel?.minimumScaleFactor = 0.5
        checkoutButton.titleLabel?.numberOfLines = 1;
        checkoutButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        numberTextField.keyboardType = UIKeyboardType.alphabet
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        
        print(checkedOut)
        print(barcodes)
        print(error)
        
        numberTextField.text = ""
        
        if error != "" { //redirected from a different view and there is an error
            errorLabel.text = error + "\nPlease try again.";
        } else {
             errorLabel.text = ""
        }
        
        if(checkedOut == "") {
            checkoutButton.isHidden = true
        } else {
            checkoutButton.isHidden = false
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //check if checking out is allowed
        self.view.isUserInteractionEnabled = false

        //check if the user is suspended
        
        let uid: String = Auth.auth().currentUser!.uid
        
        ref.child("All Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
          let status = value?["Status"] as? String ?? ""
          
            if(status == "2") { //suspended
                self.performSegue(withIdentifier: "BackToHome", sender: self)
            } else {
                self.checkCanCheckout() //check if the user can checkout
            }

          // ...
          }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    
    }
    
    func checkCanCheckout() {
        ref.child(self.PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
          let checkout = value?["CanCheckout"] as? String ?? ""
          
            if(checkout == "yes") {
                let currentTime: String = UserDefaults.standard.object(forKey:"UserSession") as? String ?? ""
                
                if(currentTime == "" || self.tooLate(currentTime: currentTime)) {
                    //go to scanning barcode
                    self.performSegue(withIdentifier: "scanSession", sender: self)
                }
                self.view.isUserInteractionEnabled = true

            } else {
                self.performSegue(withIdentifier: "BackToHome", sender: self)
            }
            

          // ...
          }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    }
    
    func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss_"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    func tooLate(currentTime: String) -> Bool{
        let rightNow: String = generateCurrentTimeStamp()
        
        let times1 = getTimes(t: currentTime) //last time the user scanned in
        let times2 = getTimes(t: rightNow) //time right now
        
        for i in 0..<4 {
            if(times2[i] > times1[i]) { //late by a year, month, day, or hour
                return true
            }
        }
        
        let minuteDifference = times2[4] - times1[4]
        
        return minuteDifference >= timeDifference //5 minutes or under, you can checkout
        
    }
    
    func getTimes(t: String) -> [Int] { //given a time stamp, returns the times separately
        var time = t
        
        var s: [Int] = []
        
        
        while(time.count > 0) {
            let separate = time.substring(to: time.indexDistance(of: "_")!)
            s.append(Int(separate) ?? 0)
            time = time.substring(from: time.indexDistance(of: "_")! + 1)
        }
        
        return s
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToManual"{ //person manually entered title
            let destinationVC = segue.destination as? manualViewController
            
            var title = numberTextField.text ?? ""
            title = title.filterEmoji
            
            destinationVC?.manualTitle = title
            destinationVC?.checkedOut = checkedOut
            destinationVC?.barcodes = barcodes
            checkedOut = "" //reset
            barcodes = "" //reset
            error = ""
        } else if(segue.identifier == "camera") { //person wants to scan barcode
            let destinationVC = segue.destination as? QRScannerController
            destinationVC?.checkedOut = checkedOut
            destinationVC?.barcodes = barcodes
            checkedOut = "" //reset
            barcodes = "" //reset
            error = ""
        } else if(segue.identifier == "GoToCheckout") { //person wants to scan barcode
            let destinationVC = segue.destination as? checkoutViewController
            destinationVC?.foodItems = checkedOut
            destinationVC?.barcodes = barcodes
            checkedOut = "" //reset
            barcodes = "" //reset
            error = ""
        } else if(segue.identifier == "scanSession") { //person wants to scan barcode
            let destinationVC = segue.destination as? BarcodeScanEntryViewController
            //don't reset fooditems, barcodes, or errors
        } else if(segue.identifier == "BackToHome") { //person wants to scan barcode
            let destinationVC = segue.destination as? homeViewController
            destinationVC?.message = "The admin has disabled checking out. Please try again later or contact them for more information."
        }
    }
    
    @IBAction func unwindToQRCode(_ unwindSegue: UIStoryboardSegue) {
        
    }

    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}

public class TimeStamp {
    public func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss_"
        return (formatter.string(from: Date()) as NSString) as String
    }
}
