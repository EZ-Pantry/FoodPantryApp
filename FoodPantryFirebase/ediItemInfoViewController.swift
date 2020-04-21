//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
var changeImageName = ""
class ediItemInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemInfoTextField: UITextField!
    @IBOutlet weak var itemAllergiesTextField: UITextField!
    @IBOutlet weak var itemTypeTextField: UITextField!
    @IBOutlet weak var itemHealthyTextField: UITextField!
    
    @IBOutlet weak var itemQuantityTextField: UITextField!
    //data of the food item, set in another view controller
    
    @IBOutlet weak var changeImageButton: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var finishButton: UIButton!
    
    var PantryName: String = ""
    
    var activeField: UITextField!
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
    
    //for type
    let yourPicker2 = UIPickerView()
    var pickerData2: [String] = [String]()//data which can be selected via pickerView
    
    //for allergy
    let yourPicker3 = UIPickerView()
    var pickerData3: [String] = [String]()//data which can be selected via pickerView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        
        
        
        ref = Database.database().reference()
        
        finishButton.layer.cornerRadius = 15
        finishButton.clipsToBounds = true
        
        finishButton.titleLabel?.minimumScaleFactor = 0.5
        finishButton.titleLabel?.numberOfLines = 1;
        finishButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        changeImageButton.layer.cornerRadius = 15
        changeImageButton.clipsToBounds = true
        
        changeImageButton.titleLabel?.minimumScaleFactor = 0.5
        changeImageButton.titleLabel?.numberOfLines = 1;
        changeImageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if(image != "") {
            if(newImageURLFromChanged == ""){
                if(image.verifyUrl){
                    itemImageView.load(url: URL(string: String(image))!)
                }
            }
            else{
                itemImageView.load(url: URL(string: String(newImageURLFromChanged))!)
            }
            
            
        } else {
            itemImageView.image = UIImage(named: "foodplaceholder.jpeg")
        }
        
        itemNameTextField.text = name;
        changeImageName = name;
        newImageURLFromChanged = ""
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
        
        yourPicker2.delegate = self
        yourPicker2.dataSource = self
        
        itemTypeTextField.inputView = yourPicker2
        pickerData2 = ["Snack", "Breakfast", "Lunch", "Dinner", "Drink"]
        
        yourPicker3.delegate = self
        yourPicker3.dataSource = self
        
        itemAllergiesTextField.inputView = yourPicker3
        pickerData3 = ["None", "Dairy", "Eggs", "Peanuts", "Tree Nuts", "Shellfish", "Wheat", "Soy", "Fish", "Other"]
                

    }
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(ediItemInfoViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(ediItemInfoViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if(image != "") {
            if(newImageURLFromChanged == ""){
                if(image.verifyUrl){
                    itemImageView.load(url: URL(string: String(image))!)
                }
            }
            else{
                itemImageView.load(url: URL(string: String(newImageURLFromChanged))!)
            }
            
            
        } else {
            itemImageView.image = UIImage(named: "foodplaceholder.jpeg")
        }
        itemNameTextField.delegate = self;
        itemInfoTextField.delegate = self;
        itemAllergiesTextField.delegate = self;
        itemTypeTextField.delegate = self;
        itemHealthyTextField.delegate = self
        itemQuantityTextField.delegate = self;
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if(pickerView == yourPicker) {
            return pickerData.count
        } else if(pickerView == yourPicker2) {
            return pickerData2.count
        }
        return pickerData3.count
        
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        if(pickerView == yourPicker) {
            return pickerData[row]
        } else if(pickerView == yourPicker2) {
            return pickerData2[row]
        }
        return pickerData3[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     
        if(pickerView == yourPicker) {
            itemHealthyTextField.text = pickerData[row]
        } else if(pickerView == yourPicker2) {
            itemTypeTextField.text = pickerData2[row]
        } else {
             itemAllergiesTextField.text = pickerData3[row]
        }
        
    }
    
    
    
    func setFirebaseData(){
        self.ref.child(self.PantryName).child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            var c: Int = 0
            
            let myGroup = DispatchGroup()

            
            for child in snapshot.children {
                myGroup.enter()
                self.view.isUserInteractionEnabled = false;
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
                    
                    if(self.image != "") {
                        if(newImageURLFromChanged != ""){
                            self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(self.itemBeingEditedID).child("URL").setValue(newImageURLFromChanged);
                        }
                    }
                    
                }
                c += 1
                
                myGroup.leave()
            }
            
            myGroup.notify(queue: .main) {
                //https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing/46852224
                self.view.isUserInteractionEnabled = true;
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
