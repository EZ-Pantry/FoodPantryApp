//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
import MapKit
import UserNotifications
import Firebase

class homeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var welcomeNameLbl: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var schoolImageView: UIImageView!
    
    @IBOutlet var adminUpdateLabel: UILabel!
    var PantryName: String = ""
    
    var ref: DatabaseReference!
    
    var foodItemsOfLowQuantity : [[String: Any]] = []
    var foodItemsOfLowQuantityNumbers: [Int] = []
    var stringOfLowFoodItems: [String] = []
    
    var alert = LoadingBar()
    
    var message = ""
    
    //for the map alert
    var installedNavigationApps : [String] = ["Apple Maps", "Google Maps"] // Apple Maps is always installed
    var latitude: Double = 45.5088
    var longitude: Double = -73.554
    
    @IBOutlet var welcomeView: UIView!
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
        
        //firebase persistance is great in that if you delete the app, the user will still stay logged in.
        //this isn't helpful when you sign in with your account, delete the app, and then get brought
        //to the home screen and an error pops up saying that pantry name doesn't exist
        
        
        self.ref = Database.database().reference()
        
                
        let myGroup = DispatchGroup()
            
        alert.showLoadingAlert()
        
        if(!UserDefaults.contains("Pantry Name")) {
            
            myGroup.enter()
            let uid = Auth.auth().currentUser!.uid
            
            ref.child("All Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let pantry = value?["Pantry Name"] as? String ?? "" //load in the admin code
              self.PantryName = pantry
                UserDefaults.standard.set(pantry, forKey: "Pantry Name")
                myGroup.leave()
            // ...
            }) { (error) in
                RequestError().showError()
                print(error.localizedDescription)
            }
            
        } else {
             myGroup.enter()
            self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
             myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
           
            self.mapView.delegate = self
            
            
            self.setUpNotications();
            //input any address and within 200 meters are shown
                        
            self.getPantryLocation(callback: {(success, location)-> Void in
                
                if(success) {
                    print("location")
                    print(location)
                    var address: String = location
                    var pantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
                    self.coordinates(forAddress: location) {
                                       (location) in
                                       guard let location = location else {
                                           // Handle error here.
                                           return
                                       }
                        self.longitude = location.longitude
                        self.latitude = location.latitude
                        
                                       self.openMapForPlace(lat: location.latitude, long: location.longitude)//helper function to show the zooming in of map into address inputed which corresponds with school
                                        let annotation = MKPointAnnotation()
                                            annotation.title = address
                                            //You can also add a subtitle that displays under the annotation such as
//                                            annotation.subtitle = address
                                            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                            self.mapView.addAnnotation(annotation)
                                   }
                    
                    
                    self.mapView.isZoomEnabled = true;
                    self.mapView.isScrollEnabled = true;
                    self.mapView.isUserInteractionEnabled = true;
                }
               
            })
            
                        
            self.getUsersName()//helper function to display user data about last time they came
            self.displayMascotURL();
            
            //replace school name below
            let userID = Auth.auth().currentUser?.uid
            self.ref.child(self.PantryName).child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                var adminValue = value?["Admin"] as? String ?? "" //loads in the code from firebase
                if(adminValue == "Yes"){
                    self.sendOutNotification();
                }
                
              }) { (error) in
                print(error.localizedDescription)
            }
            
            //self.checkUserStatus()
            
            self.getPermissionForNotifications();
            
            self.alert.hideLoadingAlert()
            
        
        }
        
        adminUpdateLabel.layer.borderColor = UIColor.black.cgColor
        adminUpdateLabel.layer.borderWidth = 7.0
        adminUpdateLabel.layer.cornerRadius = adminUpdateLabel.frame.height / 8
        adminUpdateLabel.layer.backgroundColor = UIColor(displayP3Red: 247/255, green: 188/255, blue: 102/255, alpha: 1).cgColor
        
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.layer.borderWidth = 7.0
        mapView.layer.cornerRadius = mapView.frame.height / 8
        
        welcomeView.layer.borderColor = UIColor.black.cgColor
        welcomeView.layer.borderWidth = 7.0
        welcomeView.layer.cornerRadius = welcomeView.frame.height / 8
        welcomeView.layer.backgroundColor = UIColor(displayP3Red: 247/255, green: 188/255, blue: 102/255, alpha: 1).cgColor
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title
        {
            print("User tapped on annotation with title: \(annotationTitle!)")
            openMapButtonAction()
            
        }
    }
    
    //https://stackoverflow.com/questions/38250397/open-an-alert-asking-to-choose-app-to-open-map-with/60930491#60930491
    
    func openMapButtonAction() {

        let appleURL = "http://maps.apple.com/?daddr=\(self.latitude),\(self.longitude)"
        let googleURL = "comgooglemaps://?daddr=\(self.latitude),\(self.longitude)&directionsmode=driving"

        let googleItem = ("Google Map", URL(string:googleURL)!)
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]

        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            installedNavigationApps.append(googleItem)
        }
        

        let alert = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        if message != "" {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil);//presents the alert for completion
            message = ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //This view will appear function notifies the view controller that its view is about to be added to a view hierarchy.
        //Hence that problem of the view not being reloaded is fixed, and the view is loaded everytime the tab bar clicks to a certain view
        
        ref = Database.database().reference()
        
        
        if Auth.auth().currentUser != nil {
            
            if(!UserDefaults.contains("Pantry Name")) { //doesn't contain pantry name
                
                let uid = Auth.auth().currentUser!.uid
                
                ref.child("All Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                      let pantry = value?["Pantry Name"] as? String ?? "" //load in the admin code
                    self.PantryName = pantry
                      UserDefaults.standard.set(pantry, forKey: "Pantry Name")
        
                    self.displayAdminMessage()
                    self.getUsersName()//helper function to display user data about last time they came
                    self.sendOutNotification()
                // ...
                }) { (error) in
                    RequestError().showError()
                    print(error.localizedDescription)
                }
                
            } else {
                self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
                self.displayAdminMessage()
                self.getUsersName()//helper function to display user data about last time they came
                self.sendOutNotification()
            }
            
            
        }
        
    }
    
    func displayAdminMessage() {
        ref.child(self.PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.adminUpdateLabel.text = "UPDATE\n\n" + (value?["Admin Message"] as? String ?? "") //loads ithe
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
    }
    
    func checkUserStatus() {
        //check if admin allowed
        
        if Auth.auth().currentUser != nil {
        
            let user = Auth.auth().currentUser
            ref.child("All Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
             let status = value?["Account Status"] as? String ?? "" //load in the admin code
                print("checking")
                print(status)
                if(status == "2") { //user is either approved or suspended
                    let alert = UIAlertController(title: "Your Account has Been Suspended", message: "The admin has suspended this account.", preferredStyle: .alert)
                                                         
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    self.present(alert, animated: true, completion: nil);
                    print("displayed")
                } else if(status == "3") { //user is deleted
                    try! Auth.auth().signOut()
                    let alert = UIAlertController(title: "Your Account has Been Deleted", message: "The admin has deleted this account.", preferredStyle: .alert)
                                             
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                        self.performSegue(withIdentifier: "GoToFirst", sender: self)//performs segue to the home
                    }))
                    self.present(alert, animated: true, completion: nil);
                }
                
            // ...
            }) { (error) in
                RequestError().showError()
                print(error.localizedDescription)
            }
            
        }
    }
    
    
    
    
    func getPantryLocation(callback: @escaping (_ success: Bool,_ location: String)-> Void) {
        ref.child(self.PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print("got")
            let value = snapshot.value as? NSDictionary
            let location = value?["Location"] as? String ?? "" //load in the admin code
            callback(true, location)
        // ...
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
            callback(false, "")
        }
    }
    
    func getPermissionForNotifications(){
        //standard- getting permissions from user to send push notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                print("yes")
            } else {
                print("No")
            }
        }
    }
    
    func sendOutNotification(){
        //notification will be sent every 24 hours=not redundant
        getDataFromFirebase(callback: {(success)-> Void in //gets data from firebase
            if(success) {
                for x in 0..<self.foodItemsOfLowQuantityNumbers.count{
                    var quantityOfItem = self.foodItemsOfLowQuantityNumbers[x]
                    if(quantityOfItem < 10){
                        //checking if quantity of item was less than 10, indicates a notification must be send
                        if(!self.stringOfLowFoodItems.contains(self.foodItemsOfLowQuantity[x]["name"] as! String)){
                            self.stringOfLowFoodItems.append(self.foodItemsOfLowQuantity[x]["name"] as! String)
                        }
                    }
                }
                if(self.foodItemsOfLowQuantity.count != 0){
                    print("func called")
                    self.prepareNotification();
                }
                
                
                                
            }
        })
        
    }
    
    func getDataFromFirebase(callback: @escaping (_ success: Bool)->Void) {
        self.ref.child(self.PantryName).child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempData : [[String: Any]] = []
            var tempQuantityNums: [Int] = []
            var c: Int = 0
            for child in snapshot.children { //iterates through all the food items
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                //get the food item's data
                let name = value["Name"] as? String ?? ""
                let quantity = Int(value["Quantity"] as? String ?? "") ?? 0
                let id = String(c)
                
                //adds to array
                tempData.append(["name": name, "quantity": quantity, "id": id])
                tempQuantityNums.append(quantity)
                c += 1 //increments id count
            }
            
            //set instance fields below
            self.foodItemsOfLowQuantity = tempData;
            self.foodItemsOfLowQuantityNumbers = tempQuantityNums;
            
            
            callback(true)
        })
    }
    
    
    
    func prepareNotification(){
        // The UNMutableNotificationContent object contains the data of the notification.
        let content = UNMutableNotificationContent()
        content.title = "Check Food Items Inventory"
        content.subtitle = "Looks like there are some items less than 10 quantity"
        var stringOfItemsBelowQuantity = ""
        for i in 0..<self.stringOfLowFoodItems.count{
            stringOfItemsBelowQuantity = self.stringOfLowFoodItems[i] + ", " + stringOfItemsBelowQuantity
        }
        content.body = "Items: \(stringOfItemsBelowQuantity)"
                
                
        // An UNNotificationRequest is generated which will trigger at the timeinterval of 180 seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
                
        // Notification is scheduled for delivery.
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
    }
    
    
    
    var mascotURL = "";
    func displayMascotURL(){
        ref.child(self.PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value as? NSDictionary
            print(value)
            
            
            self.mascotURL = value?["School Image"] as? String ?? ""
            self.schoolImageView.load(url: URL(string: String(self.mascotURL))!)
            
          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    
    func setUpNotications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {didAllow,  error in
            if didAllow{
                
            }
            else{
                
            }
        })
    }
    
    
    var fullName: String = "";
    
    
     func getUsersName(){
          //Purpose of function is to display specific user stats @ home screen
          let userID = Auth.auth().currentUser?.uid
          ref.child(PantryName).child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["First Name"] as? String ?? ""
              let lastName = value?["Last Name"] as? String ?? ""
              let fullName = firstName + " " + lastName
            let lastCheckedOutDate = value?["Last Date Visited"] as? String ?? ""
            let lastItemCheckedOut = value?["Last Item Checked Out"] as? String ?? ""
            self.welcomeNameLbl.text = "Welcome to " + self.PantryName.uppercased() + "\n" + fullName
//              self.lastCheckedOutLbl.text = "Last visited: \(lastCheckedOutDate)"//Display last item user checked out
//              self.lastItemCheckedOutLbl.text = "Last Checked Out Item: \(lastItemCheckedOut)"//And the last date they visited
              
              //all code with snapshot must be in here
            // ...
            }) { (error) in
              print(error.localizedDescription)
          }
          
      }
    
    
    @IBAction func logOutUser(_ sender: UIButton) {
        //Purpose is to log out the user
        try!  Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)//send user back to the login in/sign up view
    }

    
    
    public func openMapForPlace(lat:Double = 0, long:Double = 0, placeName:String = "") {
        let latitude: CLLocationDegrees = lat//latitude
        let longitude: CLLocationDegrees = long//longitutde

        homeLocation = CLLocation(latitude: latitude, longitude: longitude)//GLLocation coordinates of displayment
        
        mapView.showsUserLocation = true
        centerMapOnLocation(location: homeLocation)//open the map @ desired locaiton
    }
    
    var homeLocation = CLLocation();
    let regionRadius: CLLocationDistance = 150//distance of zoom
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)//Locates where the reigion where the longitude and latitude put it
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        //Purpose of function is to translate a string address into geocoordinates
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {}
    
}

private var kAssociationKeyMaxLength: Int = 0
private var kAssociationKeyMaxLengthTextView: Int = 0
extension UITextField {


    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }

    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }

        let selection = selectedTextRange

        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)

        selectedTextRange = selection
    }
}


extension UserDefaults {
    static func contains(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else {
            return false
        }
        return unicodeScalars.count == 1 &&
            (firstProperties.isEmojiPresentation ||
                firstProperties.generalCategory == .otherSymbol)
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        return (unicodeScalars.count > 1 &&
               unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector })
            || unicodeScalars.allSatisfy({ $0.properties.isEmojiPresentation })
    }

    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}

extension String {
    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }

    var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }
    
    var filterEmoji: String {
        return filter { !($0.isEmoji) }
    }

    var emojis: [Character] {
        return filter { $0.isEmoji }
    }

    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
}
