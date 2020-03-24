//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
class adminViewController: UIViewController {

    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet weak var adminControlsButton: UIButton!
    @IBOutlet weak var schoolIDTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet var schoolIDLabel: UILabel!
    @IBOutlet var allergiesLabel: UILabel!
    
    var current_schoolID = ""
    var currentFirstName = ""
    var currentLastName = ""
    var currentAllergies = ""
    var PantryName: String = ""

    var ref: DatabaseReference!//referncing the database
    var isActuallyAdmin = false;//boolean to check if the admin controls button is visible
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        //Create rounded buttons
        saveButton.layer.cornerRadius = 15
        saveButton.clipsToBounds = true
        
        saveButton.titleLabel?.minimumScaleFactor = 0.5
        saveButton.titleLabel?.numberOfLines = 1;
        saveButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        adminControlsButton.layer.cornerRadius = 15
        adminControlsButton.clipsToBounds = true
        
        adminControlsButton.titleLabel?.minimumScaleFactor = 0.5
        adminControlsButton.titleLabel?.numberOfLines = 1;
        adminControlsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        ref = Database.database().reference()
        prepareButton();
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func adminControlsButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toAdminControls", sender: nil)
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        handleSaving();
    }
    
    func prepareButton(){
        let userID = Auth.auth().currentUser?.uid
        ref.child(self.PantryName).child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value as? NSDictionary
            self.currentFirstName = value?["First Name"] as? String ?? ""
            self.currentLastName = value?["Last Name"] as? String ?? ""
            self.current_schoolID = value?["ID Number"] as? String ?? ""
            self.currentAllergies = value?["Allergies"] as? String ?? ""
            
            self.firstNameField.text = self.currentFirstName
            self.lastNameField.text = self.currentLastName
            self.schoolIDTextField.text = self.current_schoolID
            self.allergiesTextField.text = self.currentAllergies
            
            let adminValue = value?["Admin"] as? String ?? ""
            
            if(adminValue == "Yes"){
                self.adminControlsButton.isHidden = false;//that admin controls button only appears if the user entered the admin code when signing up
                self.schoolIDTextField.isHidden = true
                self.allergiesTextField.isHidden = true
                self.schoolIDLabel.isHidden = true
                self.allergiesLabel.isHidden = true
            }
          // ...
          }) { (error) in
              RequestError().showError()
              print(error.localizedDescription)
          }
    }
    
    func handleSaving(){
        //Purpose of function is to set the new changes in firebase under Users Node
        let userID = Auth.auth().currentUser?.uid//get logged in user
        
        guard let firstName = firstNameField.text else { return }
        guard let lastName = lastNameField.text else { return }
        guard var schoolIDNumber = schoolIDTextField.text else { return }
        guard var allergies = allergiesTextField.text else { return }
        
        if(schoolIDNumber.count >= 4) {
            if((schoolIDNumber.substring(with: 0..<3)) == "000"){
                //makes sure ID number is just the numbers without the zeroes
                schoolIDNumber = schoolIDNumber.substring(from: 3);
            }
        }
        
        if allergies == "" {
            allergies = "none"
        }
        
        if(firstName != currentFirstName){
            self.ref.child(self.PantryName).child("Users").child(userID!).child("First Name").setValue(firstName.filterEmoji)//set new name
            currentFirstName = firstName
        }
        
        if(lastName != currentLastName){
            self.ref.child(self.PantryName).child("Users").child(userID!).child("Last Name").setValue(lastName.filterEmoji)//set new name
            currentLastName = lastName
        }
        
        if(schoolIDNumber != current_schoolID){
            self.ref.child(self.PantryName).child("Users").child(userID!).child("ID Number ").setValue(schoolIDNumber.filterEmoji)//set new id #
        }
        if(allergies != currentAllergies){
            self.ref.child(self.PantryName).child("Users").child(userID!).child("Allergies ").setValue(allergies.filterEmoji)//set any new allergies in list format(i.e grass, roots, plants).
        }
        
        let alert = UIAlertController(title: "Changes Saved!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);//presents the alert for completion
    }
    
        
    
}
