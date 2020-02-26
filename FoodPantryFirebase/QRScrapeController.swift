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
    
    var maxQuantity: Int = 0
    
    override func viewDidAppear(_ animated: Bool) { //https://stackoverflow.com/questions/29257670/alertcontroller-is-not-in-the-window-hierarchy
        super.viewDidAppear(animated)

//        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
//
//        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.style = UIActivityIndicatorView.Style.gray
//        loadingIndicator.startAnimating();
//
//        alert.view.addSubview(loadingIndicator)
//        present(alert, animated: true, completion: nil)
//        print("showed")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //show loading indicator
    
        
            ref = Database.database().reference()
        getData { (title, ingredients, url) in
            DispatchQueue.main.async {
                print(title)
                if(title == "no food" || title == "error") {
                    self.errorMessage = ingredients;
                     self.performSegue(withIdentifier: "barcodeError", sender: self)
                } else {
                    
                    //check if it is in the database
                    
                    self.getFoodDataFromFirebase(callback: {(data, items)-> Void in
                        
                        if(items.contains(title)) { //inside data
                            var index: Int = items.firstIndex(of: title)!

                            let quantity: Int = Int(data[index]["quantity"] as! String) ?? 0
                            self.maxQuantity = quantity
                            if(quantity <= 0) {
                                self.errorMessage = "this food item has ran out";
                                self.performSegue(withIdentifier: "barcodeError", sender: self)
                            } else {
                            
                            self.food_title = title;
                            self.nameLabel.text = title;
                            self.ingredientsLabel.text = data[index]["information"] as! String
                            
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
                            
                            self.healthyLabel.text = data[index]["healthy"] as! String

                            var text = ""
                            var str: String = self.checkedOut
                            
                            while str.count > 0 {
                                let food = str.substring(to: str.indexDistance(of: "$")!)
                                str = str.substring(from: str.indexDistance(of: "$")! + 1)
                                let quantity = str.substring(to: str.indexDistance(of: ";")!)
                                text += "Food: " + food + ", Quantity: " + quantity + "\n\n"
                                str = str.substring(from: str.indexDistance(of: ";")! + 1)
                            }
                            
                            self.currentLabel.text = text
                            
                            }
                        } else {
                            self.errorMessage = "food item not found in the inventory";
                            self.performSegue(withIdentifier: "barcodeError", sender: self)
                        }
                        
                        
                        
                    })
                    
                
                    
                }
            }
        }
                
        checkoutButton.layer.cornerRadius = 15
        checkoutButton.clipsToBounds = true
           
        addMoreButton.layer.cornerRadius = 15
        addMoreButton.clipsToBounds = true
        
        quantityField.text = quantity
        quantityField.keyboardType = UIKeyboardType.numberPad
        
        
        
    }
    
    func getFoodDataFromFirebase(callback: @escaping (_ data: [[String: Any]], _ names: [String])->Void) {
        self.ref = Database.database().reference()
        
        
        self.ref.child("Conant High School").child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempData : [[String: Any]] = []
            var tempNames: [String] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let name = value["Name"] as? String ?? ""
                let url = value["URL"] as? String ?? ""
                let checked = value["Checked Out"] as? String ?? ""
                let healthy = value["Healthy"] as? String ?? ""
                let quantity = value["Quantity"] as? String ?? ""
                let type = value["Type"] as? String ?? ""
                let info = value["Information"] as? String ?? ""
                let id = String(c)
                
                tempData.append(["name": name, "quantity": quantity, "amountCheckedOut": checked, "information": info, "healthy": healthy, "image": url, "id": id])
                tempNames.append(name)
                c += 1
            }
            
             callback(tempData, tempNames)
        })
    }

    
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
            //FIREBASE ADDITON OCCUR HERE
               
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
    

    
    @IBAction func changedQuantity(_ sender: Any) {
        
        var currentQuantity: Int = Int(quantityField.text as! String)!
        
        if currentQuantity <= 0 {
            quantityField.text = "1"
        } else if currentQuantity > maxQuantity {
            quantityField.text = String(maxQuantity)
        }
        
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        checkedOut += food_title + "$" + quantityField.text! + ";"
        
        //check to see if there are any food titles that are duplictated
        
        var items: [String] = []
        var quantities: [Int] = []
        
        var str: String = checkedOut
        
        print(checkedOut)
        
        while str.count > 0 {
            let food = str.substring(to: str.indexDistance(of: "$")!)
            print(food)
            items.append(food)
            str = str.substring(from: str.indexDistance(of: "$")! + 1)
            let quantity = str.substring(to: str.indexDistance(of: ";")!)
            print(quantity)
            quantities.append(Int(quantity) ?? 0)
            str = str.substring(from: str.indexDistance(of: ";")! + 1)

        }
        
        var merged : [[String: Any]] = []
        
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
            
            print(matched)
            print(items)
            
            for i in 0..<matched.count{
                items.remove(at: matched[i])
                quantities.remove(at: matched[i])
                matched = matched.map{ $0 - 1 } //subtracts 1 from every match since the array decreased in size
            }
            
            merged.append(["name": food, "quantity": quantity])
            
        }
        
//        print(checkedOut)
//        print("changed")
        checkedOut = ""
        
        for val in merged {
            checkedOut += (val["name"] as! String) + "$" + String(val["quantity"] as! Int) + ";"
            print(val["name"] as! String)
            print(String(val["quantity"] as! Int))
        }
        
//        print(checkedOut)
        
        
        //continue with segue
        if segue.identifier == "barcodeError"{
            
            let destinationVC = segue.destination as? QRCodeViewController
            destinationVC?.error = errorMessage
            destinationVC?.checkedOut = checkedOut
        } else if(segue.identifier == "addMore") {
            let destinationVC = segue.destination as? QRCodeViewController
            destinationVC?.checkedOut = checkedOut
        } else if(segue.identifier == "checkOut") {
            let destinationVC = segue.destination as? checkoutViewController
            print("checking out")
            destinationVC?.foodItems = checkedOut
            print("set")
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

