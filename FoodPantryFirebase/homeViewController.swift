//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
import MapKit
class homeViewController: UIViewController {

    @IBOutlet weak var lastItemCheckedOutLbl: UILabel!
    @IBOutlet weak var lastCheckedOutLbl: UILabel!
    @IBOutlet weak var welcomeNameLbl: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        self.mapView.isZoomEnabled = false;
        self.mapView.isScrollEnabled = false;
        self.mapView.isUserInteractionEnabled = false;
        setUpNotications();
        //input any address and within 200 meters are shown
        coordinates(forAddress: "700 E Cougar Trail, Hoffman Estates, IL 60169") {
            (location) in
            guard let location = location else {
                // Handle error here.
                return
            }
            self.openMapForPlace(lat: location.latitude, long: location.longitude)//helper function to show the zooming in of map into address inputed which corresponds with school
        }
        
        ref = Database.database().reference()
        
        
        getUsersName()//helper function to display user data about last time they came
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //This view will appear function notifies the view controller that its view is about to be added to a view hierarchy.
        //Hence that problem of the view not being reloaded is fixed, and the view is loaded everytime the tab bar clicks to a certain view
        
        print("here appear")
        ref = Database.database().reference()
        if Auth.auth().currentUser != nil {
            getUsersName()//helper function to display user data about last time they came
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
    
    func sendingOut(){
        let content = UNMutableNotificationContent();
        content.body = "Looks like this item is running low on supply! Be sure to purchase more"
        content.badge = 1;
        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: nil)
    }
    
    var fullName: String = "";
    
    
    func getUsersName(){
        //Purpose of function is to display specific user stats @ home screen
        let userID = Auth.auth().currentUser?.uid
        ref.child("Conant High School").child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
          let firstName = value?["First Name"] as? String ?? ""
            let lastName = value?["Last Name"] as? String ?? ""
            let fullName = firstName + lastName
            print(fullName)
          let lastCheckedOutDate = value?["Last Date Visited"] as? String ?? ""
          let lastItemCheckedOut = value?["Last Item Checked Out"] as? String ?? ""
          self.welcomeNameLbl.text = "Welcome, \(fullName)"
            self.lastCheckedOutLbl.text = "Last visited: \(lastCheckedOutDate)"//Display last item user checked out
            self.lastItemCheckedOutLbl.text = "Last Checked Out Item: \(lastItemCheckedOut)"//And the last date they visited
            
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
