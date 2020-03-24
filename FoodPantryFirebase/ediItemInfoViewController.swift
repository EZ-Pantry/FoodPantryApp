//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
class ediItemInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemInfoTextField: UITextField!
    @IBOutlet weak var itemAllergiesTextField: UITextField!
    @IBOutlet weak var itemTypeTextField: UITextField!
    @IBOutlet weak var itemHealthyTextField: UITextField!
    
    @IBOutlet weak var itemQuantityTextField: UITextField!
    //data of the food item, set in another view controller
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var finishButton: UIButton!
    
    var PantryName: String = ""
    
    var name = ""
    var quantity = ""
    var information = ""
    var checkedout = ""
    var healthy = ""
    var image = ""
    var allergies = ""
    var type = ""
    
    var ref: DatabaseReference! //ref to db
    
    var itemBeingEditedID = "";//barcode number letters associated with item
    
    //for healthy or not healthy
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()//data which can be selected via pickerView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        ref = Database.database().reference()
        
        finishButton.layer.cornerRadius = 15
        finishButton.clipsToBounds = true
        
        finishButton.titleLabel?.minimumScaleFactor = 0.5
        finishButton.titleLabel?.numberOfLines = 1;
        finishButton.titleLabel?.adjustsFontSizeToFitWidth = true
        if(image != "") {
            itemImageView.load(url: URL(string: String(image))!)
        } else {
            itemImageView.image = UIImage(named: "foodplaceholder.jpeg")
        }
        
        itemNameTextField.text = name;
        itemInfoTextField.text = information;
        itemAllergiesTextField.text = allergies;
        itemTypeTextField.text = type;
        itemHealthyTextField.text = healthy;
        itemQuantityTextField.text = quantity;
        
        //healthy picker
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        itemHealthyTextField.inputView = yourPicker
        pickerData = ["Yes", "No"]
                

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     itemHealthyTextField.text = pickerData[row]
    }
    
    
    
    func setFirebaseData(){
        self.ref.child(self.PantryName).child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            var c: Int = 0
            
            let myGroup = DispatchGroup()

            
            for child in snapshot.children {
                myGroup.enter()
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let nameOfItem = value["Name"] as? String ?? ""
                if(nameOfItem == self.name){
                    self.itemBeingEditedID = key;//get the barcode/id for the item to set it's data later
//                    self.itemBeingEditedID = "-" + self.itemBeingEditedID
                    //set all the fields which admin changed
                    guard let editedName = self.itemNameTextField.text else { return }
                    guard let editedInfo = self.itemInfoTextField.text else { return }
                    guard let editedAllergies = self.itemAllergiesTextField.text else { return }
                    guard let editedType = self.itemTypeTextField.text else { return }
                    guard let editedHealthy = self.itemHealthyTextField.text else { return }
                    guard let editedQuantity = self.itemQuantityTextField.text else { return }
                    
                    self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Name").setValue(editedName);
                    self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Information").setValue(editedInfo);
                    self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Allergies").setValue(editedAllergies);
                    self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Type").setValue(editedType);
                    self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Healthy").setValue(editedHealthy);
                    self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("Quantity").setValue(editedQuantity);
                }
                c += 1
                myGroup.leave()
            }
            
            myGroup.notify(queue: .main) { //https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing/46852224
                self.performSegue(withIdentifier: "GoBack", sender: self)

            }
            //use dispatch groups to fire an asynchronous callback when all your requests finish.
            
            
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        
        
        
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        setFirebaseData();
    }
    

}
