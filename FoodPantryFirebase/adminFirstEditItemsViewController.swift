//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseStorage

class adminFirstEditItemsViewController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource {
    
    //inventory page
    
    //colletion view
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchFoodBear: UISearchBar! //search bar
    
    //picker view for deciding sorting of the food items
    @IBOutlet var pickerField: UITextField!
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()
    
    //picker view for deciding filtering of the food items
    @IBOutlet var pickerField2: UITextField!
    let yourPicker2 = UIPickerView()
    var pickerData2: [String] = [String]()
    
    var ref: DatabaseReference! //ref to db
    
    //properties of the item cell
    var estimateWidth = 160.0
    var cellMarginSize = 16.0
    
   //all the data for the food items
    var allData : [[String: Any]] =  []
    //sorted data
    var changedData : [[String: Any]] =  []
    
    //selected food items after they have been searched for
    var selectedFoodItem: [String: Any]?
        
    var PantryName: String = ""
    
    var currentFilter = "No Order"
    var currentSorter = "All Items"
    
    var searchText: String = "" //what the user searched for
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        ref = Database.database().reference()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.searchFoodBear.delegate = self
        self.searchFoodBear.returnKeyType = .done;
        self.searchFoodBear.enablesReturnKeyAutomatically = false
        
        //picker view
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        pickerField.inputView = yourPicker
        
        pickerData = ["No Order", "Quantity", "A-Z", "Z-A"] //sets the values for the picker view
        
        //picker view 2
               
        yourPicker2.delegate = self
        yourPicker2.dataSource = self
        pickerField2.inputView = yourPicker2
               
        pickerData2 = ["All Items", "Healthy", "Not Healthy", "Snack", "Breakfast", "Lunch", "Dinner", "Drink"] //sets the values for the picker view
        
        // Register cells
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
            
        // SetupGrid view
        self.setupGridView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
        print("done")
    }
    
    
    @IBAction func dismissBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func showLoadingAlert() { //shows a loading indicator on the screen
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        let top: UIViewController = UIApplication.topViewController()!
        
        top.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }
    
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == yourPicker) { return pickerData.count }
        return pickerData2.count    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        if(pickerView == yourPicker) { return pickerData[row] }
        return pickerData2[row]
    }
    
    //when the picker view is changed
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       if(pickerView == yourPicker) {
           pickerField.text = pickerData[row]
           currentSorter = pickerData[row]
       } else {
           pickerField2.text = pickerData2[row]
           currentFilter = pickerData2[row]
       }
       
       applyFilterSort(filter: currentFilter, sort: currentSorter)
        
    }
    
    func applyFilterSort(filter: String, sort: String) {
        
        //apply sort first
        
        if(searchText == "") {
             changedData = allData
         } else {
             changedData = filterArray(dataValues: allData, searchText: searchText)
         }
                
        if(sort == "No Order") {
            //do nothing
        } else if(sort == "Quantity") {
            changedData = changedData.sorted { Int($0["quantity"] as! String) ?? 0 > Int($1["quantity"] as! String) ?? 0 }
        } else if(sort == "A-Z") {
            changedData = changedData.sorted { ($0["name"] as! String).lowercased() < ($1["name"] as! String).lowercased() }
        } else if(sort == "Z-A") {
            changedData = changedData.sorted { ($0["name"] as! String).lowercased() > ($1["name"] as! String).lowercased() }
        }
        
        //apply filter next
        
        if(filter == "All Items") {
            //do nothing
        } else if(filter == "Healthy") {
            changedData = changedData.filter { ($0["healthy"] as! String).lowercased() == "yes" }
        } else if(filter == "Not Healthy") {
            changedData = changedData.filter { ($0["healthy"] as! String).lowercased() == "no" }
        } else if(filter == "Snack") {
            changedData = changedData.filter { ($0["type"] as! String).lowercased() == "snack" }
        } else if(filter == "Breakfast") {
            changedData = changedData.filter { ($0["type"] as! String).lowercased() == "breakfast" }
        } else if(filter == "Lunch") {
            changedData = changedData.filter { ($0["type"] as! String).lowercased() == "lunch" }
        } else if(filter == "Dinner") {
            changedData = changedData.filter { ($0["type"] as! String).lowercased() == "dinner" }
        } else if(filter == "Drink") {
            changedData = changedData.filter { ($0["type"] as! String).lowercased() == "drink" }
        }
        
        collectionView.reloadData()
        
    }
    
    //gets data from firebase (found in other views)
    
    func getDataFromFirebase(callback: @escaping (_ success: Bool)->Void) {
        self.ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
                
        self.ref.child(self.PantryName).child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempData : [[String: Any]] = []
            var c: Int = 0
            for child in snapshot.children { //iterates through all the food items
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                //get the food item's data
                let name = value["Name"] as? String ?? ""
                let url = value["URL"] as? String ?? ""
                let checked = value["Checked Out"] as? String ?? ""
                let healthy = value["Healthy"] as? String ?? ""
                let quantity = value["Quantity"] as? String ?? ""
                let type = value["Type"] as? String ?? ""
                let info = value["Information"] as? String ?? ""
                let allergies = value["Allergies"] as? String ?? ""
                let id = String(c)
                
                //adds to array
                tempData.append(["name": name, "quantity": quantity, "amountCheckedOut": checked, "information": info, "healthy": healthy, "image": url, "type": type, "allergies": allergies, "id": id, "uid": key])
                c += 1 //increments id count
            }
            
            //sets to instance field
            self.allData = tempData
            
            
             callback(true)
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    }
    
    //loads an image
    func loadImageFromFirebase(url: String, order: String, callback: @escaping (_ img: UIImage,_ order: String)->Void) { //loads an image based on the url, passed in an id and url
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: url)!) {
                let image = UIImage(data: data)
                callback(image ?? UIImage(named: "foodplaceholder.jpeg")!, order) //returns a ui image
            }
        }
    }
    
    //page is refreshed

    @IBAction func refreshPage(_ sender: Any) {
        refresh()
    }
    
    
    @IBAction func dismissBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        showLoadingAlert()
        getDataFromFirebase(callback: {(success)-> Void in //gets data from firebase
            if(success) { //same as the code in the viewDidLoad()
                let myGroup = DispatchGroup()
                
                
                
                for i in 0..<self.allData.count {
                    myGroup.enter()
                    let imageURL = self.allData[i]["image"] as! String
                                       
                    if(imageURL == "") {
                        self.allData[i]["view"] = UIImage(named: "foodplaceholder.jpeg")
                        myGroup.leave()
                        
                    }
                    else if(!imageURL.verifyUrl){
                        print(imageURL)
                        print("not verified")
                        self.allData[i]["view"] = UIImage(named: "foodplaceholder.jpeg")
                        myGroup.leave()
                    } else {
                    print(imageURL)
                    print("good")
                        
                    self.loadImageFromFirebase(url: imageURL, order: String(i), callback: {(img, order)-> Void in

                               for i in 0..<self.allData.count {
                                   if (self.allData[i]["id"] as! String == order) {
                                       self.allData[i]["view"] = img
                                   }
                               }
                            myGroup.leave()


                           })
                       }
                    }
                myGroup.notify(queue: .main) {
                     self.dismiss(animated: false)
                    
                    self.searchText = ""
                    self.currentFilter = "No Order"
                    self.currentSorter = "All Items"
                    self.pickerField2.text = "All Items"
                    self.pickerField.text = "No Order"
                    self.applyFilterSort(filter: self.currentFilter, sort: self.currentSorter)
                    
                     self.collectionView.reloadData()
                }

                 }
        })
    }
    
    
    //item cell methods
    
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

        let index = indexPath[1]
        selectedFoodItem = changedData[index] //data is based on the selected food item
               
        self.performSegue(withIdentifier: "toItemPopover2", sender: self) //shows pop up view
    }
    
    //segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemPopover2"{
            let destinationVC = segue.destination as? adminEditPopUpViewController
            destinationVC?.name = (selectedFoodItem?["name"] as? String)!
            destinationVC?.quantity = (selectedFoodItem?["quantity"] as? String)!
            destinationVC?.checkedout = (selectedFoodItem?["amountCheckedOut"] as? String)!
            destinationVC?.information = (selectedFoodItem?["information"] as? String)!
            destinationVC?.healthy = (selectedFoodItem?["healthy"] as? String)!
            destinationVC?.image = (selectedFoodItem?["image"] as? String)!
            destinationVC?.type = (selectedFoodItem?["type"] as? String)!
            destinationVC?.allergies = (selectedFoodItem?["allergies"] as? String)!
            destinationVC?.uid = (selectedFoodItem?["uid"] as? String)!
        }
    }
    
    @IBAction func dismissBackToControls(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension adminFirstEditItemsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return changedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell

        cell.layer.cornerRadius = cell.frame.height / 6
        
        cell.setData(text: (self.changedData[indexPath.row]["name"] as! String).trimTitle())
            
        if(self.changedData[indexPath.row]["view"] != nil) {
            cell.itemImageView.image = self.changedData[indexPath.row]["view"] as! UIImage
        }
    
        return cell
    }
    
    
}


extension adminFirstEditItemsViewController: UICollectionViewDelegateFlowLayout {
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

extension adminFirstEditItemsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        
        applyFilterSort(filter: currentFilter, sort: currentSorter)
        
        collectionView.reloadData()
    }

    func filterArray(dataValues: [[String: Any]], searchText: String) -> ([[String: Any]]) {
        var newValues: [[String: Any]] = []
        
        var count = 0
        for item in dataValues {
            if ((item["name"] as! String).contains(searchText)) {
                newValues.append(dataValues[count])
            }
            count += 1
        }
        return newValues
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        changedData = allData
        applyFilterSort(filter: currentFilter, sort: currentSorter)

        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    @IBAction func unwindToAdminEdit(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        refresh()

    }
    
    
}





