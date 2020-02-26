//
//  FoodItemsSecondViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/20/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage
var itemClickedName = ""
var itemClickedImageURL = ""
var itemClickedQuantity = ""
var refreshOccurred = false;
class FoodItemsSecondViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchFoodBear: UISearchBar!
    
    
    var ref: DatabaseReference!
    
    let dataArray = ["Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran (Islamic Republic of)", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati"]
    
    var barcodeDataArray = [String]()
    var foodItemsNameDataArray = [String]()
    var storage: Storage!
    var foodItemsImageArray = [String]()
    var foodItemsQuantityArray = [String]()
    
    var searchedFoodItem = [String]()
    var searchedFoodItemImage = [String]()
    var searchedFoodItemQuantity = [String]()
    
    var searching = false
    
    //when with firebase
    //need to get all food item names
    //and food item images through the url

    var estimateWidth = 160.0
    var cellMarginSize = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //initialize storage below
        
    
        populateWithFirebaseData(callback: {(success)-> Void in
            print("all done")
            print(self.searchedFoodItem)
            // Set Delegates
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.searchFoodBear.delegate = self
            // Register cells
            self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
            
            // SetupGrid view
            self.setupGridView()
        });
    
    }
    
    
    
    
    var counter = 0 ;
    func populateWithFirebaseData(callback: @escaping (_ success: Bool) -> Void){
        ref.child("Conant High School").child("Inventory").child("Food Items").observe(.childAdded) { (snapshot) in
            for key in [snapshot.key] {
                //getting each barcode number(1024294) here
                self.barcodeDataArray.append(key)
            }
            for i in 0..<self.barcodeDataArray.count{
                self.counter += 1;
                self.ref.child("Conant High School").child("Inventory").child("Food Items").child(self.barcodeDataArray[i]).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                    let value = snapshot.value as? NSDictionary
                    let foodItemName = value?["Name"] as? String ?? ""
                    let foodItemURL = value?["URL"] as? String ?? ""
                    let foodItemQuantity = value?["Quantity"] as? String ?? ""
                    if self.foodItemsNameDataArray.contains(foodItemName) {
                        //dont do anything
                    }
                    else{
                        self.foodItemsNameDataArray.append(foodItemName)
                    }
                    
                    if self.foodItemsImageArray.contains(foodItemURL) {
                        //dont do anything
                    }
                    else{
                        self.foodItemsImageArray.append(foodItemURL)
                    }
                    
                    //problem area
                    if self.foodItemsQuantityArray.contains(foodItemQuantity){

                    }
                    else{
                        self.foodItemsQuantityArray.append(foodItemQuantity)
                    }
                    callback(true)
                })
            }
        }
       
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        if(refreshOccurred){
                    if searching {
                        print("food items name array below")
                        print(foodItemsNameDataArray)
                        print("index path below")
                        print(indexPath)
                        print(searchedFoodItem[indexPath.row])
                        itemClickedName = searchedFoodItem[indexPath.row]
                        itemClickedImageURL = searchedFoodItemImage[indexPath.row]
                        itemClickedQuantity = searchedFoodItemQuantity[indexPath.row]
                    } else {
                        print(foodItemsNameDataArray[indexPath.row])
                        itemClickedName = foodItemsNameDataArray[indexPath.row]
                        itemClickedImageURL = foodItemsImageArray[indexPath.row]
                        itemClickedQuantity = foodItemsQuantityArray[indexPath.row]
                    }
                }
                else{
                    if searching {
                        print(searchedFoodItem[indexPath.row])
                        itemClickedName = searchedFoodItem[indexPath.row]
                        itemClickedImageURL = "backbuttonimage.png"
                        itemClickedQuantity = ""
                    } else {
                        print(dataArray[indexPath.row])
                        itemClickedName = dataArray[indexPath.row]
                        itemClickedImageURL = "backbuttonimage.png"
                        itemClickedQuantity = ""
                    }
                }
        self.performSegue(withIdentifier: "toItemPopover", sender: self)
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
//        print(self.barcodeDataArray)
        print(self.foodItemsNameDataArray)
//        print(self.foodItemsImageArray)
        print(self.foodItemsQuantityArray)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            refreshOccurred = true;
        }
    }
}

extension FoodItemsSecondViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searching {
            print("searched food item array count below")
            print(searchedFoodItem.count)
            return searchedFoodItem.count
        } else {
            if(refreshOccurred){
                return foodItemsNameDataArray.count
            }
            else{
               return dataArray.count
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        //SEARCHED FOOD ITEM ARRAY!!!!!
        if(refreshOccurred){
            if searching {
                print("food items name array below")
                print(foodItemsNameDataArray)
                print("index path below")
                print(indexPath)
                cell.setData(text: searchedFoodItem[indexPath.row])
                cell.load(url: URL(string: searchedFoodItemImage[indexPath.row])!);
            } else {
                cell.setData(text: foodItemsNameDataArray[indexPath.row])
                cell.load(url: URL(string: foodItemsImageArray[indexPath.row])!);
            }
        }
        else{
            if searching {
                cell.setData(text: searchedFoodItem[indexPath.row])
                cell.setImage(text: "backbuttonimage.png")
            } else {
//                cell.setData(text: dataArray[indexPath.row])
                cell.setData(text: self.dataArray[indexPath.row])
                cell.setImage(text: "backbuttonimage.png")
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
        if(refreshOccurred){
            searchedFoodItemImage.removeAll();
            searchedFoodItem = foodItemsNameDataArray.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
            //for loop and get positions and matchup
            for i in 0..<self.searchedFoodItem.count{
                let indexOfSearchedFoodItem = foodItemsNameDataArray.firstIndex(of: searchedFoodItem[i])
                searchedFoodItemImage.append(foodItemsImageArray[indexOfSearchedFoodItem!])
                searchedFoodItemQuantity.append(foodItemsQuantityArray[indexOfSearchedFoodItem!])
            }
            print("searched food item below")
            print(searchedFoodItem)
        }
        else{
           searchedFoodItem = dataArray.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        }
        print("search text below")
        print(searchText)
        searching = true
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        collectionView.reloadData()
    }
    
    
    
}

