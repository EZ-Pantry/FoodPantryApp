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
    
    
    var foodItems = ["Mac N Cheese", "Penne Pasta", "Granola Bars", "Veggie Soup", "Chicken Soup"]
    
    var data : [[String: Any]] =  [
        ["name": "Mac N Cheese", "quantity": "32", "amountCheckedOut": "2", "information": "a", "healthy": "no", "image": "https://www.spendwithpennies.com/wp-content/uploads/2018/03/Instant-Pot-Mac-and-Cheese-23.jpg"],
        ["name": "Penne Pasta","quantity": "15", "amountCheckedOut": "3", "information": "b", "healthy": "yes",  "image": "https://www.thespruceeats.com/thmb/Bq4rhtzhsh-Mqgb3dSGAjmQCwcM=/1365x2048/filters:fill(auto,1)/easy-penne-pasta-bake-with-tomatoes-3058843-12_preview-5b2bd0f9119fa80037137e25.jpeg"],
        ["name": "Granola Bars","quantity": "18", "amountCheckedOut": "4", "information": "c", "healthy": "no",  "image": "https://images-na.ssl-images-amazon.com/images/I/913Cm3tsw2L._SX679_.jpg"],
        ["name": "Veggie Soup","quantity": "25", "amountCheckedOut": "1", "information": "d", "healthy": "yes",  "image": "https://thecozyapron.com/wp-content/uploads/2018/07/vegetable-soup_thecozyapron_1.jpg"],
        ["name": "Chicken Soup","quantity": "5", "amountCheckedOut": "10", "information": "efhiuhlsajhasfjhl", "healthy": "no",  "image": "https://www.inspiredtaste.net/wp-content/uploads/2018/12/Homemade-Chicken-Noodle-Soup-Recipe-Video.jpg"]
    ]
        
    var sortedData : [[String: Any]] =  []
    
    var selectedFoodItem: [String: Any]?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize storage below
        storage = Storage.storage()
         ref = Database.database().reference()
        
        
        getDataFromFirebase(callback: {(success)-> Void in
            if(success) {
                // Set Delegates
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.searchFoodBear.delegate = self
                // Register cells
                self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
                
                // SetupGrid view
                self.setupGridView()
            } else {
                print("something went wrong")
            }
        })
        
    }
    
    func getDataFromFirebase(callback: @escaping (_ success: Bool)->Void) {
        var uidList: [String] = []
               
               ref.child("Conant High School").child("Inventory").child("Food Items").observe(.childAdded) { (snapshot) in
                   for key in [snapshot.key] {
                       //getting each uid here
                       uidList.append(key)
                   }
                   
                   var tempData : [[String: Any]] = []
                   var tempNames: [String] = []
                   
                   for i in 0..<uidList.count{
                       self.ref.child("Conant High School").child("Inventory").child("Food Items").child(uidList[i]).observeSingleEvent(of: .value, with: { (snapshot) in
                       // Get user value
                           let value = snapshot.value as? NSDictionary
                           let name = value?["Name"] as? String ?? ""
                           let url = value?["URL"] as? String ?? ""
                           let checked = value?["Checked Out"] as? String ?? ""
                           let healthy = value?["Healthy"] as? String ?? ""
                           let quantity = value?["Quantity"] as? String ?? ""
                           let type = value?["Type"] as? String ?? ""
                           let info = value?["Information"] as? String ?? ""
                           tempData.append(["name": name, "quantity": quantity, "amountCheckedOut": checked, "information": info, "healthy": healthy])
                           tempNames.append(name)
                       })
                   }
                   
                   self.data = tempData
                   self.foodItems = tempNames
                
                 callback(true)
                   
               }
        callback(false)
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
            cell.itemImageView.load(url: URL(string: img)!)
            print("ran inside here")
        } else {
            cell.setData(text: foodItems[indexPath.row])
            var img: String = data[indexPath.row]["image"] as! String
            cell.itemImageView.load(url: URL(string: img)!)
            print("ran here")
        }
        return cell
    }
    
    
}


extension FoodItemsSecondViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        print("clicked")
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
