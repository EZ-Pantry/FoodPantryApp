//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class QRAddViewController: UIViewController {
    
    //first screen admin sees when adding items 
    
    @IBOutlet var addManualButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var foodTitle: UITextField!
    
    var error = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addManualButton.layer.cornerRadius = 15
        addManualButton.clipsToBounds = true
        
        addManualButton.titleLabel?.minimumScaleFactor = 0.5
        addManualButton.titleLabel?.numberOfLines = 1;
        addManualButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if error != "" {
            errorLabel.text = error
        }
        
        foodTitle.text = ""
    }
    
    @IBAction func addManually(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToManual", sender: self) //go to qr scrape controller
    }
    
    @IBAction func dismissBack(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToManual"{
            let destinationVC = segue.destination as? chooseManualViewController
            
            var title = self.foodTitle.text as! String
            title = title.filterEmoji
            
            destinationVC?.manualTitle = title
            
            error = ""
            
        } else if segue.identifier == "GoToScan"{
            let destinationVC = segue.destination as? addItemViewController
            
            error = ""
        }
    }
    
    @IBAction func unwindToQRAdd(_ unwindSegue: UIStoryboardSegue) {}
    
}
