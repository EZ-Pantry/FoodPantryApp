//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase


class checkoutViewController: UITableViewController {
    
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    var foodItems = ""
    var barcodes = ""
    
    var items: [String] = []
    var quantities: [Int] = []
    
    var ref: DatabaseReference!
    var PantryName: String = ""
    
    var data: [[String: Any]] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        //update with today's date
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"//in month/day/year format
//        MM-dd-yyyy- no need
        self.fullyFormatedDate = formatter.string(from:NSDate.init(timeIntervalSinceNow: 0) as Date)//the current date in literal format
        
        self.finishButton.layer.cornerRadius = 15//round buttons
        self.finishButton.clipsToBounds = true
        
        finishButton.titleLabel?.minimumScaleFactor = 0.5
        finishButton.titleLabel?.numberOfLines = 1;
        finishButton.titleLabel?.adjustsFontSizeToFitWidth = true

        self.backButton.layer.cornerRadius = 15
        self.backButton.clipsToBounds = true
        
        backButton.titleLabel?.minimumScaleFactor = 0.5
        backButton.titleLabel?.numberOfLines = 1;
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        setCheckoutItems(currentItems: foodItems)

        // Do any additional setup after loading the view.
    }
    
    func setCheckoutItems(currentItems: String) {
        
        self.data = []
        self.items = []
        self.quantities = []
        
        self.getFoodDataFromFirebase(callback: {(data)-> Void in
                   
                   //gets the images of every food item
                   var nameToImage: [String: Any] = [:]
                   
                   let myGroup = DispatchGroup()

                   
                   for i in 0..<data.count {
                       let name = data[i]["name"] as! String
                       let url = data[i]["image"] as! String
                       myGroup.enter()
                       
                       self.loadImage(url: url, callback: {(loadedImage)-> Void in
                           nameToImage[name] = loadedImage
                           myGroup.leave()
                       })
                   }
                   
                   
                   myGroup.notify(queue: .main) {
                       
                       //converts the string of food items into readeable text using the delimiters
                       
                       var text = ""
                       var str: String = currentItems
                       
                       while str.count > 0 {
                           let food = str.substring(to: str.indexDistance(of: "$")!)
                           self.items.append(food)
                           str = str.substring(from: str.indexDistance(of: "$")! + 1)
                           let quantity = str.substring(to: str.indexDistance(of: ";")!)
                           self.quantities.append(Int(quantity) ?? 0)
                                               
                           self.data.append(["food": food, "quantity": quantity, "image": nameToImage[food]])
                           
                           text += "Item: " + food + "\nQuantity: " + quantity + "\n\n"
                           str = str.substring(from: str.indexDistance(of: ";")! + 1)
                       }
                       
                       self.tableView.reloadData()
                                       
                   }
                   
                   
               
               })
    }
    
    func loadImage(url: String, callback: @escaping (_ img: UIImage)->Void) { //loads an image based on the url, passed in an id and url
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: url)!) {
                let image = UIImage(data: data)
                callback(image!) //returns a ui image
            }
        }
    }
    
    @IBAction func finish(_ sender: Any) {
                //update firebase database
               self.getFoodDataFromFirebase(callback: {(data)-> Void in
                    print("recieved data")
                    print(data)
        
                var keyList: [[String: Any]] = []
        
                    for i in 0..<self.items.count {
                        var key: String = self.getIdFromTitle(title: self.items[i], data: data)
                        keyList.append(["key": key, "quantity": self.quantities[i]])
                    }
        
                    self.updateFirebase(keyList: keyList, callback: {() -> Void in
                        print("done changing")
                        self.performSegue(withIdentifier: "GoToHome", sender: self)
                    })
                })
    }
    
    
    var fullyFormatedDate : String = ""
    func updateFirebase(keyList : [[String: Any]], callback: @escaping () -> Void) {
        print("now changing data")
        
        let myGroup = DispatchGroup()
        
        var totalQuantityChanged = 0
        
        for value in keyList {
            
            myGroup.enter() //https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing
            
            let key = value["key"] as? String
            let quantityChanged = value["quantity"] as! Int
            
            self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(key!).observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
                let value = snapshot.value as? NSDictionary
                
                
                var quantity = Int(value?["Quantity"] as? String ?? "") ?? 0
                quantity -= quantityChanged;//number of items checked out would go here
                
                if (quantity < 0) { //make sure quantity isn't negative
                    quantity = 0;
                }
                
                self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(key!).child("Quantity").setValue(String(quantity));
                
                var checkedOut = Int(value?["Checked Out"] as? String ?? "") ?? 0
                checkedOut += quantityChanged;//number of items checked out would go here
                self.ref.child(self.PantryName).child("Inventory").child("Food Items").child(key!).child("Checked Out").setValue(String(checkedOut));
                
                totalQuantityChanged += quantityChanged
                
                myGroup.leave()
               
              // ...
              }) { (error) in
                  RequestError().showError()
                  print(error.localizedDescription)
              }
            
        }
        
        if(self.items.count > 0) {
        
        myGroup.enter()
        let userID = Auth.auth().currentUser?.uid
        self.ref.child(self.PantryName).child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value as? NSDictionary
            //UPDATE Statistics Node
            
            //update that the student has checked out quantity number more items
            
            var totalItemsStudentHasCheckedOut = Int(value?["Total Item's Checked Out"] as? String ?? "") ?? 0
            print("total student has: ")
            print(totalItemsStudentHasCheckedOut)
            totalItemsStudentHasCheckedOut += totalQuantityChanged;//number of items checked out would go here
            self.ref.child(self.PantryName).child("Users").child(userID!).child("Total Item's Checked Out").setValue(String(totalItemsStudentHasCheckedOut))
            
            
            
            self.ref.child(self.PantryName).child("Users").child(userID!).child("Last Date Visited").setValue(self.fullyFormatedDate)
            
            self.ref.child(self.PantryName).child("Users").child(userID!).child("Last Item Checked Out").setValue(self.items[self.items.count-1])
            
            myGroup.leave()
          // ...
          }) { (error) in
              RequestError().showError()
              print(error.localizedDescription)
          }
        
        //update statistics node with data below
        print("formatted date below")
        print(self.fullyFormatedDate)
        myGroup.enter()

        self.ref.child(self.PantryName).child("Statistics").child("Total Visits").observeSingleEvent(of: .value, with: { (snapshot) in
                    
          var dateNodesArray: [String] = [String]()
          var c: Int = 0
          for child in snapshot.children {
              let snap = child as! DataSnapshot
              let key = snap.key as String
              dateNodesArray.append(key)
              c += 1
              //retrieving the keys from total visits
          }
          var dateNodeHasBeenFound = false;
          
          for i in 0..<dateNodesArray.count{
              if(dateNodesArray[i] == self.fullyFormatedDate){
                  dateNodeHasBeenFound = true;
              }
          }
          
          if(!dateNodeHasBeenFound){
              print("new node created")
              //Create a new node for that day
              self.ref.child(self.PantryName).child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Items").setValue(String(totalQuantityChanged));
              self.ref.child(self.PantryName).child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Students Visited").setValue(String(1));
          }
          else{
              //Update the created stats node for that day
              print("node already created")
              print("date below")
              print(self.fullyFormatedDate)
              self.ref.child(self.PantryName).child("Statistics").child("Total Visits").child(self.fullyFormatedDate).observeSingleEvent(of: .value, with: { (snapshot) in
                  let value = snapshot.value as? NSDictionary
                  var itemsCheckedOutThatDay = Int(value?["Items"] as? String ?? "") ?? 0
                  var studentsVisitedThatDay = Int(value?["Students Visited"] as? String ?? "") ?? 0
                  print("items checked out that day  \(itemsCheckedOutThatDay)")
                  print("visited that day \(studentsVisitedThatDay)")
                  itemsCheckedOutThatDay += totalQuantityChanged;//number of items checked out would go here
                  studentsVisitedThatDay+=1;
                  self.ref.child(self.PantryName).child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Items").setValue(String(itemsCheckedOutThatDay));
                  self.ref.child(self.PantryName).child("Statistics").child("Total Visits").child(self.fullyFormatedDate).child("Students Visited").setValue(String(studentsVisitedThatDay));
              }) { (error) in
                  RequestError().showError()
                  print(error.localizedDescription)
              }
              
              
              
          }
          myGroup.leave()
        // ...
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        }
        myGroup.notify(queue: .main) { //https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing/46852224
            print("Finished all requests.")
            callback()
        }
        
    }
    
    func getIdFromTitle(title: String, data: [[String: Any]]) -> String {
        
        for i in 0..<data.count {
            if ((data[i]["name"] as? String) == title) {
                return data[i]["key"] as! String
            }
        }
        
        return ""
        
    }
    
    func getFoodDataFromFirebase(callback: @escaping (_ data: [[String: Any]]) -> Void) {
        self.ref = Database.database().reference()
        
        
        self.ref.child(self.PantryName).child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempData : [[String: Any]] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key as String
                let value: [String: Any] = snap.value as! [String : Any]
                let name = value["Name"] as? String ?? ""
                let quantity = value["Quantity"] as? String ?? ""
                let image = value["URL"] as? String ?? ""
                
                tempData.append(["name": name, "quantity": quantity, "key": key, "image": image])
                c += 1
            }
            
             callback(tempData)
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CheckoutCell1TableViewCell", owner: self, options: nil)?.first as! CheckoutCell1TableViewCell
        
        //https://stackoverflow.com/questions/20655060/get-button-click-inside-uitableviewcell
        cell.tapCallback = { //when the x button is clicked, remove the food item
            //remove the food item
            
            var str: String = self.foodItems
            print("------------------------")
            print(str)
            
            let foodItem: String = self.data[indexPath.row]["food"] as! String
            print(foodItem)
            let food: Int = str.indexDistance(of: foodItem)! //get the index of the food item
            str = str.substring(from: food) //chop off everything before the food item
            let delimiter: Int = str.indexDistance(of: ";")! + food + 1//get the index of the delimiter, and you gotta add on the part u chopped off
            
            let quantity = str.substring(to: str.indexDistance(of: ";")!)
            self.quantities.append(Int(quantity) ?? 0)
            
            
            self.foodItems = self.foodItems.substring(to: food) + self.foodItems.substring(from: delimiter)
            
            //update
            print("*********************")
            print(self.foodItems)
            
            self.setCheckoutItems(currentItems: self.foodItems)
            
            self.backButton.isHidden = true
            
        }
        
        cell.foodImage.image = self.data[indexPath.row]["image"] as! UIImage
        cell.foodTitle.text = self.data[indexPath.row]["food"] as! String
        cell.foodQuantity.text = "Quantity: " + (self.data[indexPath.row]["quantity"] as! String)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 312
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

           if segue.identifier == "GoToHome"{
                let destinationVC = segue.destination as? homeViewController
           } else if segue.identifier == "BackToCodeView" {
                let destinationVC = segue.destination as? QRCodeViewController
                destinationVC?.checkedOut = foodItems;
                destinationVC?.barcodes = barcodes;
                destinationVC?.error = "";
            }

        }
               
               
}
    

