//
//  ViewController.swift
//  GridViewExampleApp
//
//  Created by Chandimal, Sameera on 12/22/17.
//  Copyright © 2017 Pearson. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage
class FoodItemsSecondViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchFoodBear: UISearchBar!
    
    
    var storage: Storage!
    var foodItemsImageArray = [UIImage]()
    var ref: DatabaseReference!
    
    var searchedFoodItem = [String]()
    
    var searching = false

    var estimateWidth = 160.0
    var cellMarginSize = 16.0
        
    var foodItems = ["Mac N Cheese", "Penne Pasta", "Granola Bars", "Veggie Soup"]
    
    var data : [[String: Any]] =  [
        ["name": "Mac N Cheese", "quantity": "32", "amountCheckedOut": "2", "information": "a", "healthy": "no", "image": "https://www.spendwithpennies.com/wp-content/uploads/2018/03/Instant-Pot-Mac-and-Cheese-23.jpg", "id": "0"],
        ["name": "Penne Pasta","quantity": "15", "amountCheckedOut": "3", "information": "b", "healthy": "yes",  "image": "https://www.thespruceeats.com/thmb/Bq4rhtzhsh-Mqgb3dSGAjmQCwcM=/1365x2048/filters:fill(auto,1)/easy-penne-pasta-bake-with-tomatoes-3058843-12_preview-5b2bd0f9119fa80037137e25.jpeg", "id": "1"],
        ["name": "Granola Bars","quantity": "18", "amountCheckedOut": "4", "information": "c", "healthy": "no",  "image": "https://images-na.ssl-images-amazon.com/images/I/913Cm3tsw2L._SX679_.jpg", "id": "2"],
        ["name": "Veggie Soup","quantity": "25", "amountCheckedOut": "1", "information": "d", "healthy": "yes",  "image": "https://thecozyapron.com/wp-content/uploads/2018/07/vegetable-soup_thecozyapron_1.jpg", "id": "3"]
    ]
            
    var sortedData : [[String: Any]] =  []
        
    var selectedFoodItem: [String: Any]?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize storage below
        storage = Storage.storage()
        
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.searchFoodBear.delegate = self
        
        
        
        // Register cells
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
            
        // SetupGrid view
        self.setupGridView()
        
        
        getDataFromFirebase(callback: {(success)-> Void in
            if(success) {
                for i in 0..<self.data.count {
                    self.loadImageFromFirebase(url: self.data[i]["image"] as! String, order: String(i), callback: {(img, order)-> Void in
                               print("got " + String(i))
                               
                               for i in 0..<self.data.count {
                                   if (self.data[i]["id"] as! String == order) {
                                       self.data[i]["view"] = img
                                   }
                               }
                               
                               DispatchQueue.main.async {
                                   self.collectionView.reloadData()
                                   print("all reloaded with the stuff " + String(i))
                               }
                           })
                       }
            }
        })
        
    }
    
    
    func sortAtoZ() {
        data = data.sorted { ($0["name"] as! String).lowercased() < ($1["name"] as! String).lowercased() }
        foodItems = foodItems.sorted { $0.lowercased() < $1.lowercased() }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            print("sorted a-z")
        }
    }
    
    func sortZtoA() {
           data = data.sorted { ($0["name"] as! String).lowercased() > ($1["name"] as! String).lowercased() }
           foodItems = foodItems.sorted { $0.lowercased() < $1.lowercased() }
           DispatchQueue.main.async {
               self.collectionView.reloadData()
               print("sorted a-z")
           }
       }
    
    func getDataFromFirebase(callback: @escaping (_ success: Bool)->Void) {
        self.ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        print(userID)
        
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
            
            self.data = tempData
            self.foodItems = tempNames
            
            
             callback(true)
        })
    }
    
    func loadImageFromFirebase(url: String, order: String, callback: @escaping (_ img: UIImage,_ order: String)->Void) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: url)!) {
                let image = UIImage(data: data)
                callback(image!, order)
            }
        }
    }
    
    @IBAction func refreshPage(_ sender: Any) {
        getDataFromFirebase(callback: {(success)-> Void in
            if(success) {
                for i in 0..<self.data.count {
                    self.loadImageFromFirebase(url: self.data[i]["image"] as! String, order: String(i), callback: {(img, order)-> Void in
                        print("got " + String(i))
                       
                        for i in 0..<self.data.count {
                           if (self.data[i]["id"] as! String == order) {
                               self.data[i]["view"] = img
                           }
                       }
                       
                       DispatchQueue.main.async {
                           self.collectionView.reloadData()
                           print("all reloaded with the stuff " + String(i))
                       }
                   })
               }
            }
        })
//
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //handle clicking of element
        print("hello")
        print(indexPath)
        
        if(searching) {
            let index = indexPath[1]
            selectedFoodItem = sortedData[index]
        } else {
            let index = indexPath[1]
            selectedFoodItem = data[index]
        }
        
        
        self.performSegue(withIdentifier: "toItemPopover", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemPopover"{
            let destinationVC = segue.destination as? popUpViewController
            destinationVC?.name = (selectedFoodItem?["name"] as? String)!
            destinationVC?.quantity = (selectedFoodItem?["quantity"] as? String)!
            destinationVC?.checkedout = (selectedFoodItem?["amountCheckedOut"] as? String)!
            destinationVC?.information = (selectedFoodItem?["information"] as? String)!
            destinationVC?.healthy = (selectedFoodItem?["healthy"] as? String)!
            destinationVC?.image = (selectedFoodItem?["image"] as? String)!
        }
    }
}

extension FoodItemsSecondViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searching {
            return searchedFoodItem.count
        } else {
            return foodItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell

        if searching {
            cell.setData(text: searchedFoodItem[indexPath.row])
            var img: String = sortedData[indexPath.row]["image"] as! String
            if(sortedData[indexPath.row]["view"] != nil) {
                cell.itemImageView.image = sortedData[indexPath.row]["view"] as! UIImage
            }
            
        } else {
            cell.setData(text: foodItems[indexPath.row])
            let url: String = data[indexPath.row]["image"] as! String
            let id: String = data[indexPath.row]["id"] as! String
            
            if(data[indexPath.row]["view"] != nil) {
                cell.itemImageView.image = data[indexPath.row]["view"] as! UIImage
            }
            
                
            }
        return cell
    }
    
    
}


extension FoodItemsSecondViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 1.75)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

extension FoodItemsSecondViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchedFoodItem = foodItems.filter({_ in foodItems.contains(searchText)})
//        date = date.filter({_ in foodItems.contains(searchText)})
        (searchedFoodItem, sortedData) = filterArray(items: foodItems, dataValues: data, searchText: searchText)
        searching = true
        collectionView.reloadData()
    }

    func filterArray(items: [String], dataValues: [[String: Any]], searchText: String) -> ([String], [[String: Any]]) {
        var newItems: [String] = []
        var newValues: [[String: Any]] = []
        
        var count = 0
        for item in items {
            if (item.contains(searchText)) {
                newItems.append(items[count])
                newValues.append(dataValues[count])
            }
            count += 1
        }
        return (newItems, newValues)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        collectionView.reloadData()
    }
    
    
}

extension UIImageView {
    func loadHeavy(url: URL, callback: @escaping (_ success: Bool)->UICollectionViewCell) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        callback(true)
                    }
                }
            }
        }
    }
}
