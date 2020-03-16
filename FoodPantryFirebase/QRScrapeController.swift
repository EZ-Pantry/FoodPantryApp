//
//  QRScrapeController.swift
//  QRCodeReader
//
//  Created by Ashay Parikh on 2/8/20.
//  Copyright © 2020 Ashay Parikh. All rights reserved.
//

import Foundation

import UIKit
import FirebaseDatabase
import FirebaseUI
class QRScrapeController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel! //label for the name of the food item
    @IBOutlet var ingredientsLabel: UILabel! //label for the ingredient
    @IBOutlet var healthyLabel: UILabel! //food item is healthy label
    @IBOutlet var typeLabel: UILabel! //type of food label
    
    @IBOutlet var checkoutButton: UIButton! //checkout button
    @IBOutlet var addMoreButton: UIButton! //adding more items button
    @IBOutlet var currentLabel: UILabel! //the current food items, listed below
    @IBOutlet var foodView: UIImageView! //the food item image
    
    var ref: DatabaseReference! //reference to the firebase database
    
    var barcode = "" //barcode (UPC number)
    var quantity = "1" //quantity of items
    
    var food_title = "" //the food title
    
    var errorMessage = ""; //the message for the error (if there is one)
    
    var checkedOut = "" //items already added to checkout list; format: food1,number1;food2,number2
    var barcodes = "" //barcodes of the items already checked out
    var maxQuantity: Int = 0 //the number of the selected food item in the database
    
    var manualEnter: Bool = false //true if the food item is manually loaded
    var manualTitle: String = "" //manual title that the user entered on the manualview (matches one of the titles in the database)
    var PantryName: String = ""
    
    var sessionQuantities = "" //how many food items remain in the food pantry

    var loadingBar = LoadingBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //makes the buttons round
        
        checkoutButton.layer.cornerRadius = 15
        checkoutButton.clipsToBounds = true
           
        addMoreButton.layer.cornerRadius = 15
        addMoreButton.clipsToBounds = true
        
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        
        //show loading indicator
        if(manualEnter) { //user manually entered title
            ref = Database.database().reference() //sets the reference
            self.getFoodDataFromFirebase(callback: {(data, items)-> Void in //gets data from firebase
                if(items.contains(self.manualTitle)) { //double check that the item list contains the manual title
                                        
                    var index: Int = items.firstIndex(of: self.manualTitle)! //gets the index within items
                    
                    let quantity: Int = Int(data[index]["quantity"] as! String) ?? 0 //max quantity of food items for the specific item
                    self.maxQuantity = quantity //sets to a variable
                                        
                    if(quantity <= 0) { //item has run out
                        self.errorMessage = "this food item has ran out";
                        self.performSegue(withIdentifier: "barcodeError", sender: self) //redirect to QRCodeView
                    } else {
                        self.food_title = self.manualTitle; //sets to a variable
                        self.nameLabel.text = self.manualTitle; //puts on the screen
                        
                        var ingredients = data[index]["information"] as! String //information/ingredients for the food item
                        var url = data[index]["image"] as! String //url for the image of the food item
                        var foodAllergy = data[index]["allergies"] as! String
                        
                        self.ingredientsLabel.text = ingredients //puts on the screen
                        
                        //determines allergies based on the information in ingredients
                        var allergies = ["corn", "egg", "fish", "milk", "nut", "soy", "wheat"]
                    
                        var confirmed = ""
                        
                        //checks to see if the title or ingredients contain an allergy
                        for allergy in allergies {
                            if self.manualTitle.contains(allergy) { //title
                                confirmed += allergy + ","
                            }  else if(ingredients.contains(allergy)) { //ingredients
                                confirmed += allergy + ","
                            } else if(foodAllergy.contains(allergy)) { //ingredients
                                confirmed += allergy + ","
                            }
                        }
                    
                        //none confirmed
                        if confirmed == "" {
                            confirmed = "none,"
                        }
                    
                        self.typeLabel.text = confirmed.substring(to: confirmed.count-1); //removes the comma at the end, puts on the screen
                    
                    
                        if url != "" { //only loads the url if there is one
                            self.foodView.load(url: URL(string: url)!);
                        }
                    
                        self.healthyLabel.text = data[index]["healthy"] as! String //puts healthy info on the screen
                    
                        //update checkout
                        
                        self.checkedOut = self.formatCheckout(currentCheckout: self.checkedOut, newItem: self.food_title)
                        
                        //takes the checkout info and cleans and reformats it
                    
                        var text = ""
                        var str: String = self.checkedOut
                                        
                        while str.count > 0 {
                            //does substring based on the delimiters
                            let food = str.substring(to: str.indexDistance(of: "$")!)
                            str = str.substring(from: str.indexDistance(of: "$")! + 1)
                            let quantity = str.substring(to: str.indexDistance(of: ";")!)
                            text += "Food: " + food + ", Quantity: " + quantity + "\n\n"
                            str = str.substring(from: str.indexDistance(of: ";")! + 1)
                        }
                        //makes the format "Food: Item" next line "Quantity: number"
                    
                        self.currentLabel.text = text //puts on the screen
                    
                    }
                } else { //no item found, go back to the qrcodeview screen
                    self.errorMessage = "food item not found in the inventory";
                    self.performSegue(withIdentifier: "barcodeError", sender: self)
                }
                
            })
        } else { //user entered a barcode
        
            ref = Database.database().reference() //reference to database
            
            //first, check to see if this food item has already been scanned
                   
            var str: String = barcodes
            
            var found: Bool = false
            
            //splits up the string into items and their quantities
            while str.count > 0 {
                let upc = str.substring(to: str.indexDistance(of: ",")!)
                if(upc == barcode) { //already scanned
                    found = true
                    break
                }
                str = str.substring(from: str.indexDistance(of: ",")! + 1)
            }
            
            
            print(found)
            
            if(found) {
                self.errorMessage = "this food item has already been scanned";
                DispatchQueue.main.async { //async thread - https://stackoverflow.com/questions/32292600/swift-performseguewithidentifier-not-working
                    self.performSegue(withIdentifier: "barcodeError", sender: self)
                }
            } else {
            
            
        getData { (title, error) in //gets the title (string) and error (boolean)
            DispatchQueue.main.async { //async thread
                if(error) { //there is an error
                    self.errorMessage = title;
                     self.performSegue(withIdentifier: "barcodeError", sender: self) //go back to the qrcodeview screen
                } else {
                    //check if it is in the database
                    
                    self.getFoodDataFromFirebase(callback: {(data, items)-> Void in //get data from the database
                        if(items.contains(title)) { //inside data
                            let index: Int = items.firstIndex(of: title)! //gets index of the food item

                            let quantity: Int = Int(data[index]["quantity"] as! String) ?? 0 //gets the max quantity
                            self.maxQuantity = quantity //sets to var
                            if(quantity <= 0) { //food item has run out
                                self.errorMessage = "this food item has ran out";
                                self.performSegue(withIdentifier: "barcodeError", sender: self)
                            } else {
                                //more setting
                                self.food_title = title;
                                self.nameLabel.text = title;
                                
                                //even more setting
                                let ingredients: String = data[index]["information"] as! String
                                let url: String = data[index]["image"] as! String
                                self.ingredientsLabel.text = ingredients
                            
                            
                                var allergies = data[index]["allergies"] as! String
                            
                                if allergies == "" {
                                    allergies = "none"
                                }
                                
                                self.typeLabel.text = allergies
                                
                            
                                if url != "" {
                                    self.foodView.load(url: URL(string: url)!);
                                }
                            
                                self.healthyLabel.text = data[index]["healthy"] as! String
                                
                                //update checkout
                                
                                self.checkedOut = self.formatCheckout(currentCheckout: self.checkedOut, newItem: self.food_title)
                                
                                //takes the checkout info and cleans and reformats it
                            
                                var text = ""
                                var str: String = self.checkedOut
                            
                                while str.count > 0 {
                                    //does substring based on the delimiters
                                    let food = str.substring(to: str.indexDistance(of: "$")!)
                                    str = str.substring(from: str.indexDistance(of: "$")! + 1)
                                    let quantity = str.substring(to: str.indexDistance(of: ";")!)
                                    text += "Food: " + food + ", Quantity: " + quantity + "\n\n"
                                    str = str.substring(from: str.indexDistance(of: ";")! + 1)
                                }
                                //makes the format "Food: Item" next line "Quantity: number"
                            
                                self.currentLabel.text = text //puts on the screen
                            }
                                                        
                        } else { //return to the qr code view
                            print("item not found")
                            self.errorMessage = "food item not found in the inventory";
                            self.performSegue(withIdentifier: "barcodeError", sender: self)
                        }
                        
                        
                    })
                }
            }
        }
        }
        

                        
        }
        
    }

    func getFoodDataFromFirebase(callback: @escaping (_ data: [[String: Any]], _ names: [String])->Void) { //returns a dict of all the food items in the database and their data, and a list of the names of the food items
        self.ref = Database.database().reference() //gets a reference
        
        //read the database
        self.ref.child(self.PantryName).child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                tempData.append(["name": name, "quantity": quantity, "amountCheckedOut": checked, "information": info, "healthy": healthy, "image": url, "allergies": allergies, "id": id])
                tempNames.append(name)
                c += 1 //increments id counter
            }
            
             callback(tempData, tempNames) //callback function
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    }

    
     func getData(_ completion: @escaping (String, Bool) -> ()) { //request method with the barcode API, returns the title and error
       //        let baseUrl = "https://api.upcitemdb.com/prod/trial/lookup?upc="
               let baseUrl = "https://api.barcodespider.com/v1/lookup?token=c35919b64b4aa4c38752&upc=" //url
               
                var bar = barcode
        
               if bar.count > 12 { //makes the barcode 12 characters long
                   let range = bar.index(after: bar.startIndex)..<bar.endIndex
                   bar = String(bar[range])

               }
                
            let url = URL(string: baseUrl + bar) //url with the barcode
               
               let task = URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in //request
                   guard let data = data, error == nil else { return }

                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] ?? [:] //converts response to dict
                        //see https://devapi.barcodespider.com/documentation for api documentation
                    let foods = json["item_attributes"] as? [String: Any] ?? [:]//gets
                    let response = json["item_response"] as? [String: Any] ?? [:]
                    let status = response["status"] as? String ?? ""
                       if status != "OK" { //bad status
                        let message = response["message"] as? String ?? ""
                           completion(message, true) //returns the message and error = true
                       } else { //good status, returns the title
                        let title = foods["title"] as? String ?? ""
                           completion(title, false)
                       }
                   } catch {
                       print(error)
                        RequestError().showError()
                       return
                   }
                   
               }
               
               task.resume()
       }
    

    
    func formatCheckout(currentCheckout: String, newItem: String) -> String {
        var checkout: String = currentCheckout
        checkout += newItem + "$" + "1" + ";"
        //check to see if there are any food titles that are duplictated
               
        var items: [String] = []
        var quantities: [Int] = []
               
        var str: String = checkout
               
        //splits up the string into items and their quantities
        while str.count > 0 {
            let food = str.substring(to: str.indexDistance(of: "$")!)
            items.append(food)
            str = str.substring(from: str.indexDistance(of: "$")! + 1)
            let quantity = str.substring(to: str.indexDistance(of: ";")!)
            quantities.append(Int(quantity) ?? 0)
            str = str.substring(from: str.indexDistance(of: ";")! + 1)

        }
               
        var merged : [[String: Any]] = [] //all items, no duplicates
               
        //removes duplicates (could be more efficent code)
        while items.count > 0 {
            let food = items[0]
            var quantity: Int = 0
                   
            var matched: [Int] = []
                   
            for i in 0..<items.count {
                if items[i] == food {
                    quantity += quantities[i]
                    matched.append(i)
                }
            }
                   
            for i in 0..<matched.count{
                items.remove(at: matched[i])
                quantities.remove(at: matched[i])
                matched = matched.map{ $0 - 1 } //subtracts 1 from every match since the array decreased in size
            }
                   
            merged.append(["name": food, "quantity": quantity]) //adds tp the dict
                   
        }
               
        //convert dict back to string format
               
        checkout = ""
               
        for val in merged {
            checkout += (val["name"] as! String) + "$" + String(val["quantity"] as! Int) + ";"
        }
        
        return checkout
        
    }

    @IBAction func doAddMore(_ sender: Any) {
        self.performSegue(withIdentifier: "addMore", sender: self)
    }
    
    
    //segue method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //continue with segue
        if segue.identifier == "barcodeError"{
            let destinationVC = segue.destination as? QRCodeViewController
            destinationVC?.error = errorMessage
            destinationVC?.checkedOut = checkedOut
            destinationVC?.barcodes = barcodes
        } else {
            barcodes += barcode + ","
            if(segue.identifier == "addMore") {
                let destinationVC = segue.destination as? QRCodeViewController
                destinationVC?.checkedOut = checkedOut
                destinationVC?.barcodes = barcodes
                destinationVC?.error = "";
            } else if(segue.identifier == "checkOut") {
                let destinationVC = segue.destination as? checkoutViewController
                destinationVC?.foodItems = checkedOut
                destinationVC?.barcodes = barcodes
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

//extensions for substring, done buttons, and loading images

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
            , leftRange.upperBound <= rightRange.lowerBound
            else { return nil }

        let sub = self[leftRange.upperBound...]
        let closestToLeftRange = sub.range(of: right)!
        return String(sub[..<closestToLeftRange.lowerBound])
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

extension UITextField{

       @IBInspectable var doneAccessory: Bool{

        get{

            return self.doneAccessory

        }

        set (hasDone) {

            if hasDone{

                addDoneButtonOnKeyboard()

            }

        }

    }

    

    func addDoneButtonOnKeyboard()

    {

        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))

        doneToolbar.barStyle = .default

        

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        

        let items = [flexSpace, done]

        doneToolbar.items = items

        doneToolbar.sizeToFit()

        

        self.inputAccessoryView = doneToolbar

    }

    

    @objc func doneButtonAction()

    {

    self.resignFirstResponder()

    }

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension StringProtocol {
    func indexDistance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func indexDistance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

