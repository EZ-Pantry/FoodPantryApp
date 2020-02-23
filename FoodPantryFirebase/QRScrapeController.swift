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
class QRScrapeController: UIViewController {

    
    //name
    //type of food
    //ingredients
    //is healthy
    //quantity
    
    //add more
    //checkout
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ingredientsLabel: UILabel!
    @IBOutlet var healthyLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    @IBOutlet var checkoutButton: UIButton!
    @IBOutlet var addMoreButton: UIButton!
    @IBOutlet var quantityField: UITextField!
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet var foodView: UIImageView!
    
    var ref: DatabaseReference!
    
    var barcode = ""
    var quantity = ""
    
    var food_title = ""
    
    var errorMessage = "";
    
    var checkedOut = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loadig=")
        print(barcode)
        print(quantity)
        ref = Database.database().reference()
        
//        getTitle { (value) in
//            DispatchQueue.main.async {
//                print(value)
//                self.nameLabel.text = value
//            }
//        }
//
//        getIngredients { (ingredients, type) in
//            DispatchQueue.main.async {
//                self.typeLabel.text = type;
//                self.ingredientsLabel.text = ingredients
//            }
//        }
        
        getData { (title, ingredients, url) in
            DispatchQueue.main.async {
                
                if(title == "no food" || title == "error") {
                    self.errorMessage = ingredients;
                     self.performSegue(withIdentifier: "barcodeError", sender: self)
                } else {
                    self.food_title = title;
                    self.nameLabel.text = title;
                    self.ingredientsLabel.text = ingredients
                
                    var allergies = ["corn", "egg", "fish", "milk", "nut", "soy", "wheat"]
                
                    var confirmed = ""
                
                    for allergy in allergies {
                        if title.contains(allergy) {
                            confirmed += allergy + ","
                        }  else if(ingredients.contains(allergy)) {
                            confirmed += allergy + ","
                        }
                    }
                
                    if confirmed == "" {
                        confirmed = "none,"
                    }
                
                    self.typeLabel.text = confirmed.substring(to: confirmed.count-1);
                    
                    if url != "" {
                        self.foodView.load(url: URL(string: url)!);
                    }
                }
            }
        }
        
        self.healthyLabel.text = "yes"
        
        checkoutButton.layer.cornerRadius = 15
        checkoutButton.clipsToBounds = true
           
        addMoreButton.layer.cornerRadius = 15
        addMoreButton.clipsToBounds = true
        
        quantityField.text = quantity
        quantityField.keyboardType = UIKeyboardType.numberPad
        
//        let defaults = UserDefaults.standard
//
//         if let list = defaults.string(forKey: "checkoutInventory") {
//            print("list")
//            print(list)
//            currentLabel.text = "Current Items:\n\n" + list
//         } else {
//            currentLabel.text = "Current Items: none"
//        }
        
        var text = ""
        var str: String = checkedOut
        
        while str.count > 0 {
            let food = str.substring(to: str.indexDistance(of: "$")!)
            str = str.substring(from: str.indexDistance(of: "$")! + 1)
            let quantity = str.substring(to: str.indexDistance(of: ";")!)
            text += "Food: " + food + ", Quantity: " + quantity + "\n\n"
            str = str.substring(from: str.indexDistance(of: ";")! + 1)
        }
        
        currentLabel.text = text
        
    }
    
    
    
//    func getIngredients(_ completion: @escaping (String, String) -> ()) {
//        let baseUrl = "https://api.nal.usda.gov/fdc/v1/search?api_key=PsxBttjr3pGn4njqbG6WMaVxvcy6atQJCVYqvC6J&generalSearchInput="
//
//
//        if barcode.count > 12 {
//            let range = barcode.index(after: barcode.startIndex)..<barcode.endIndex
//            barcode = String(barcode[range])
//            print("changed")
//            print(barcode)
//        }
//
//
//        let url = URL(string: baseUrl + barcode)
//
//        let task = URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
//            guard let data = data, error == nil else { return }
//
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
//                print(json)
//                let foods = json?["foods"] as? [[String: Any]] ?? []
//                let message = json?["message"] as? String
//                if message != nil {
//                    completion("error", message!)
//                } else if foods.count == 0 {
//                    completion("no food", "no food item was found")
//                } else {
//                    let ingredients = foods[0]["ingredients"]
//                    let type = foods[0]["description"]
////                    print(foods[0]["scientificName"])
////                    print(foods[0]["commonNames"])
////                    print(foods[0]["fdcId"])
////                    print(foods[0]["brandOwner"])
//
//                    completion(ingredients as! String, type as! String)
//                }
//            } catch {
//                print(error)
//                return
//            }
//
//        }
//
//        task.resume()
//
//
//    }
    
     func getData(_ completion: @escaping (String, String, String) -> ()) {
       //        let baseUrl = "https://api.upcitemdb.com/prod/trial/lookup?upc="
               let baseUrl = "https://api.barcodespider.com/v1/lookup?token=c35919b64b4aa4c38752&upc="
               
               if barcode.count > 12 {
                   let range = barcode.index(after: barcode.startIndex)..<barcode.endIndex
                   barcode = String(barcode[range])
                   print("barcode below")
                   print(barcode)
               }
               
               print(barcode)
               let url = URL(string: baseUrl + barcode)
               
               let task = URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
                   guard let data = data, error == nil else { return }

                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
//                       print(json)
                       let foods = json?["item_attributes"] as? [String: Any]
                       let response = json?["item_response"] as? [String: Any]
                       let status = response?["status"] as? String
                       if status != "OK" {
                           let message = response?["message"] as? String
                           completion("error", message!, "none")
                       } else {
                           let title = foods?["title"] as? String
                           let ingredients = foods?["description"] as? String
                           let url = foods?["image"] as? String
                           completion(title as! String, ingredients as! String, url as! String)
                       }
                   } catch {
                       print(error)
                       return
                   }
                   
               }
               
               task.resume()
       }
    
//    func updateDataBase(){
//        //Whenever a student checks out an item, below is what must be updated in the databse
//        //1. Inventory Node-Decrease by amount student has checked out
//        //2. Add that one student visited the food pantry into the Statistics node
//        //3. Add that the student has checked out an item to their personal node with the user ID.
//
//
////        1
//        let userID = Auth.auth().currentUser?.uid
//        ref.child("Conant High School").child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//          // Get user value
//          let value = snapshot.value as? NSDictionary
//          let fullName = value?["Name"] as? String ?? ""
//          self.welcomeNameLbl.text = "Welcome, \(fullName)"
//
//            //all code with snapshot must be in here
//          // ...
//          }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
    
    
//    func getTitle(_ completion: @escaping (String) -> ()) {
//
//        let baseUrl = "https://www.upcitemdb.com/upc/"
//
//        let url = URL(string: baseUrl + barcode)
//
//
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//          guard let data = data else {
//            print("data was nil")
//            return
//          }
//          guard let htmlString = String(data: data, encoding: .utf8) else {
//            print("couldn't cast data into String")
//            return
//          }
//          //print(htmlString)
//
//            let leftSideString = """
//            <b>
//            """
//            let rightSideString = """
//            </b>
//            """
//            guard
//              let leftSideRange = htmlString.range(of: leftSideString)
//            else {
//              print("couldn't find left range")
//                completion("not found")
//              return
//            }
//            guard
//              let rightSideRange = htmlString.range(of: rightSideString)
//            else {
//              print("couldn't find right range")
//                completion("not found")
//              return
//            }
//            let rangeOfTheData = leftSideRange.upperBound..<rightSideRange.lowerBound
//            let valueWeWantToGrab = htmlString[rangeOfTheData]
//            completion(String(valueWeWantToGrab))
//        }
//        task.resume()
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        checkedOut += food_title + "$" + quantityField.text! + ";"

        if segue.identifier == "barcodeError"{
            
            let destinationVC = segue.destination as? QRCodeViewController
            destinationVC?.error = errorMessage
            destinationVC?.checkedOut = checkedOut
        } else if(segue.identifier == "addMore") {
            let destinationVC = segue.destination as? QRCodeViewController
            destinationVC?.checkedOut = checkedOut
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
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

