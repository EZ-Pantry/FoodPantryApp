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
    
    var searchedFoodItem = [String]()
    
    var searching = false

    var estimateWidth = 160.0
    var cellMarginSize = 16.0
    
    
    let foodItems = ["Mac N Cheese", "Penne Pasta", "Granola Bars", "Veggie Soup", "Chicken Soup"]
    
    let date : [[String: Any]] =  [
        ["quantity": 32, "amountCheckedOut": 2, "information": "a", "healthy": "no"],
        ["quantity": 15, "amountCheckedOut": 3, "information": "b", "healthy":"yes"],
        ["quantity": 18, "amountCheckedOut": 4, "information": "c", "healthy": "no"],
        ["quantity": 25, "amountCheckedOut": 1, "information": "d", "healthy":"yes"],
        ["quantity": 5, "amountCheckedOut": 10, "information": "efhiuhlsajhasfjhl", "healthy":"no"]
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize storage below
        storage = Storage.storage()
        print("hello")
        
        
        // Set Delegates
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        searchFoodBear.delegate = self
        // Register cells
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        
        // SetupGrid view
        self.setupGridView()
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
        
        self.performSegue(withIdentifier: "toItemPopover", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemPopover"{
            let destinationVC = segue.destination as? popUpViewController
            destinationVC?.name = "sample"

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
            cell.setImage(text: "soup.jpg")
            print("ran inside here")
        } else {
            cell.setData(text: foodItems[indexPath.row])
            cell.setImage(text: "soup.jpg")
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
        searchedFoodItem = foodItems.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
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
