//
//  addItemViewController.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 3/1/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase

class addMainViewController: UIViewController {

    @IBOutlet var nameLabel: UITextField!
    @IBOutlet var ingredientsLabel: UITextField!
    @IBOutlet var allergiesLabel: UITextField!
    @IBOutlet var typeLabel: UITextField!
    @IBOutlet var quantityLabel: UITextField!
    @IBOutlet var healthyLabel: UITextField!
    
    @IBOutlet var foodView: UIImageView!
    @IBOutlet var adminDirections: UILabel!
    @IBOutlet var addMoreBtn: UIButton!
    @IBOutlet var finishBtn: UIButton!
    
    var barcode = ""
    
    var food_title = "" //the food title
    var food_url = ""
    
    var errorMessage = ""
    
    var manualEnter: Bool = false //true if the food item is manually loaded
    var manualTitle: String = "" //manual title that the user entered on the manualview (matches one of the titles in the database)
    
    var ref: DatabaseReference! //reference to the firebase database
    
    var existing: Bool = false //exists in the db
    
    var food_data: [String: Any] = [:] //data for the food item
    var found: Bool = false //if found the database, used for manual enter in previus view
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        nameLabel.isUserInteractionEnabled = false
        
        if (manualEnter) { //manually entered food item
            if(found) {
                
                print(food_data)
                
                self.existing = true
                self.nameLabel.text = food_data["name"] as! String
                self.ingredientsLabel.text = food_data["information"] as! String
                self.allergiesLabel.text = food_data["allergies"] as! String
                self.typeLabel.text = food_data["type"] as! String
                self.healthyLabel.text = food_data["healthy"] as! String
                let url = food_data["image"] as! String
                self.food_url = url
                
                if url != "" {
                    self.foodView.load(url: URL(string: url)!);
                } else {
                    self.foodView.image = UIImage(named: "foodplaceholder.jpeg")
                }
                
                self.adminDirections.text = "Existing Item\nEdit the Following"
            } else {
                self.existing = false
                nameLabel.isUserInteractionEnabled = true
                self.adminDirections.text = "New Item\nAdd the Following"
            }
        } else { //used barcode
            getData { (title, error, image) in //gets the title (string) and error (boolean)
                DispatchQueue.main.async { //async thread
                    if(error) { //there is an error
                        self.errorMessage = title;
                         self.performSegue(withIdentifier: "addingError", sender: self) //go back to the qrcodeview screen
                    } else {
                        //check if it is in the database
                        
                        self.getFoodDataFromFirebase(callback: {(data, items)-> Void in //get data from the database
                            
                            if(items.contains(title)) { //food item already exists
                                self.existing = true
                                let index: Int = items.firstIndex(of: title)! //gets index of the food item
                                
                                self.food_title = title
                                self.food_data = data[index]
                                
                                let ingredients: String = data[index]["information"] as! String
                                let url: String = data[index]["image"] as! String
                                let allergies = data[index]["allergies"] as! String
                                let type = data[index]["type"] as! String
                                let healthy = data[index]["healthy"] as! String
                                
                                self.nameLabel.text = title
                                self.ingredientsLabel.text = ingredients
                                self.allergiesLabel.text = allergies
                                self.typeLabel.text = type
                                self.healthyLabel.text = healthy

                                self.food_url = url
                                
                                if url != "" {
                                    self.foodView.load(url: URL(string: url)!);
                                } else {
                                    self.foodView.image = UIImage(named: "foodplaceholder.jpeg")
                                }
                                
                                self.adminDirections.text = "Existing Item\nEdit the Following"
                                
                            } else { //new item
                                self.existing = false
                                self.food_url = image
                                self.food_title = title
                                
                                
                                self.nameLabel.text = title

                                if image != "" {
                                    self.foodView.load(url: URL(string: image)!);
                                }
                                
                                self.adminDirections.text = "New Item\nAdd the Following"

                            }
                    })
                }
            }
        }
        }
        addMoreBtn.layer.cornerRadius = 15
        addMoreBtn.clipsToBounds = true
           
        finishBtn.layer.cornerRadius = 15
        finishBtn.clipsToBounds = true
        
        //sets the keypad type
        
        quantityLabel.text = "1"
        quantityLabel.keyboardType = UIKeyboardType.numberPad
        
    }
    
    func getFoodDataFromFirebase(callback: @escaping (_ data: [[String: Any]], _ names: [String])->Void) { //returns a dict of all the food items in the database and their data, and a list of the names of the food items
        self.ref = Database.database().reference() //gets a reference
        
        //read the database
        self.ref.child("Conant High School").child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //temp data and names
            var tempData : [[String: Any]] = [] //return 1
            var tempNames: [String] = [] //return 2
            var c: Int = 0 //assigns an id to each food item
            for child in snapshot.children { //each food item
                let snap = child as! DataSnapshot
                let key = snap.key //key
                let value: [String: Any] = snap.value as! [String : Any] //values
                
                //gets the values of each food item
                let name = value["Name"] as? String ?? ""
                let url = value["URL"] as? String ?? ""
                let checked = value["Checked Out"] as? String ?? ""
                let healthy = value["Healthy"] as? String ?? ""
                let quantity = value["Quantity"] as? String ?? ""
                let type = value["Type"] as? String ?? ""
                let info = value["Information"] as? String ?? ""
                let allergies = value["Allergies"] as? String ?? ""
                let id = String(c)
                
                //adds to the arrays
                tempData.append(["name": name, "quantity": quantity, "amountCheckedOut": checked, "information": info, "healthy": healthy, "image": url, "allergies": allergies, "type": type, "id": id, "key": key])
                tempNames.append(name)
                c += 1 //increments id counter
            }
            
             callback(tempData, tempNames) //callback function
        })
    }

    
     func getData(_ completion: @escaping (String, Bool, String) -> ()) { //request method with the barcode API, returns the title and error
       //        let baseUrl = "https://api.upcitemdb.com/prod/trial/lookup?upc="
               let baseUrl = "https://api.barcodespider.com/v1/lookup?token=c35919b64b4aa4c38752&upc=" //url
               
               if barcode.count > 12 { //makes the barcode 12 characters long
                   let range = barcode.index(after: barcode.startIndex)..<barcode.endIndex
                   barcode = String(barcode[range])

               }
                
            let url = URL(string: baseUrl + barcode) //url with the barcode
               
               let task = URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in //request
                   guard let data = data, error == nil else { return }

                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] //converts response to dict
                        //see https://devapi.barcodespider.com/documentation for api documentation
                       let foods = json?["item_attributes"] as? [String: Any] //gets
                       let response = json?["item_response"] as? [String: Any]
                       let status = response?["status"] as? String
                       if status != "OK" { //bad status
                           let message = response?["message"] as? String
                           completion(message!, true, "none") //returns the message and error = true
                       } else { //good status, returns the title
                           let title = foods?["title"] as! String
                            let url = foods?["image"] as! String
                           completion(title, false, url)
                       }
                   } catch {
                       print(error)
                       return
                   }
                   
               }
               
               task.resume()
       }
    
        @IBAction func addMoreSelected(_ sender: Any) {
    
                //update firebase
                
                let myGroup = DispatchGroup() //dispatch group, needed because the for loop is async

            
                if(existing) {
                    //update the current data in firebase
                    
                    myGroup.enter()
                    
                    let key = food_data["key"] as! String
                    
                    print("key")
                    print(key)
                    
                    self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        
                        //updating ingredients, allergies, type and quantity
                        
                        var newIngredients: String = self.ingredientsLabel.text!
                        var newAllergies: String = self.allergiesLabel.text!
                        var newType: String = self.typeLabel.text!
                        var additionalQuantity: String = self.quantityLabel.text!
                        var currentQuantity = self.food_data["quantity"] as! String
                        var newQuantity = Int(additionalQuantity)! + Int(currentQuantity)!
                        var newQuantity2 = String(newQuantity)
                        var newHealthy = self.healthyLabel.text!
                        
                        //check for blanks
                        if(newIngredients == "") {
                            newIngredients = "not listed"
                        }
                        
                        if(newAllergies == "") {
                            newAllergies = "not listed"
                        }
                        
                        if(newType == "") {
                            newType = "not listed"
                        }
                        
                        if(newHealthy == "") {
                            newHealthy = "not listed"
                        }
                        
                        //now update

                        self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key).child("Information").setValue(newIngredients);
                        
                        self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key).child("Quantity").setValue(newQuantity2);
                        
                        self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key).child("Type").setValue(newType);
                        
                        self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key).child("Allergies").setValue(newAllergies);
                        
                        self.ref.child("Conant High School").child("Inventory").child("Food Items").child(key).child("Healthy").setValue(newHealthy);
                        
                        myGroup.leave() //all done, can leave the group
                      // ...
                      }) { (error) in
                        print(error.localizedDescription)
                    }
                } else {
                    //create new data
                    
                    var newTitle = self.nameLabel.text!
                    var newIngredients: String = self.ingredientsLabel.text!
                    var newAllergies: String = self.allergiesLabel.text!
                    var newType: String = self.typeLabel.text!
                    var newQuantity: String = self.quantityLabel.text!
                    var newURL = food_url
                    var checkedOut = "0"
                    var newHealthy = self.healthyLabel.text!
                    
                    //check for blanks
                    if(newIngredients == "") {
                        newIngredients = "not listed"
                    }
                    
                    if(newAllergies == "") {
                        newAllergies = "not listed"
                    }
                    
                    if(newType == "") {
                        newType = "not listed"
                    }
                    
                    let dic = NSMutableDictionary()
                    dic.setValue(newTitle, forKey: "Name")
                    dic.setValue(newIngredients, forKey: "Information")
                    dic.setValue(newAllergies, forKey: "Allergies")
                    dic.setValue(newType, forKey: "Type")
                    dic.setValue(newQuantity, forKey: "Quantity")
                    dic.setValue(newURL, forKey: "URL")
                    dic.setValue(checkedOut, forKey: "Checked Out")
                    dic.setValue(newHealthy, forKey: "Healthy")
                    
                    myGroup.enter()
                    
                    let refChild = self.ref.child("Conant High School").child("Inventory").child("Food Items").childByAutoId()
                    
                    refChild.updateChildValues(dic as [NSObject : AnyObject]) { (error, ref) in
                        if(error != nil){
                            print("Error",error)
                            myGroup.leave() //all done, can leave the group
                        } else{
                            print("\n\n\n\n\nAdded successfully...")
                            myGroup.leave() //all done, can leave the group
                        }
                    }
                    
                }
                
                myGroup.notify(queue: .main) { //all loops finished, can do the call back
                    print("Finished all requests.")
                    self.performSegue(withIdentifier: "addMore", sender: self)
                }

        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          
           //continue with segue
           if segue.identifier == "addingError"{
               let destinationVC = segue.destination as? QRAddViewController
               destinationVC?.error = errorMessage
           } else if segue.identifier == "addMore"{
            let destinationVC = segue.destination as? QRAddViewController
            
        }
       }
    
    
}
