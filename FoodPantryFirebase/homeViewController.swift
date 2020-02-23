//
//  homeViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/8/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
import MapKit
class homeViewController: UIViewController {

    @IBOutlet weak var lastItemCheckedOutLbl: UILabel!
    @IBOutlet weak var lastCheckedOutLbl: UILabel!
    @IBOutlet weak var welcomeNameLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //below is to disable user interaction w/map
        self.mapView.isZoomEnabled = false;
        self.mapView.isScrollEnabled = false;
        self.mapView.isUserInteractionEnabled = false;
        
        //map config below
        //input any address and within 200 meters are shown
        coordinates(forAddress: "700 E Cougar Trail, Hoffman Estates, IL 60169") {
            (location) in
            guard let location = location else {
                // Handle error here.
                return
            }
            self.openMapForPlace(lat: location.latitude, long: location.longitude)//helper function
        }
        
        ref = Database.database().reference()
        getUsersName()
    }
    
    var fullName: String = "";
    
    
    func getUsersName(){
        let userID = Auth.auth().currentUser?.uid
        ref.child("Conant High School").child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
          let fullName = value?["Name"] as? String ?? ""
          let lastCheckedOutDate = value?["Last Date Checked Out"] as? String ?? ""
          let lastItemCheckedOut = value?["Last Item Checked Out"] as? String ?? ""
          self.welcomeNameLbl.text = "Welcome, \(fullName)"
            self.lastCheckedOutLbl.text = "Last visited: \(lastCheckedOutDate)"
            self.lastItemCheckedOutLbl.text = "Last Checked Out Item: \(lastItemCheckedOut)"
            
            //all code with snapshot must be in here
          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func logOutUser(_ sender: UIButton) {
        try!  Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }

    public func openMapForPlace(lat:Double = 0, long:Double = 0, placeName:String = "") {
        let latitude: CLLocationDegrees = lat//latitude
        let longitude: CLLocationDegrees = long//longitutde

        homeLocation = CLLocation(latitude: latitude, longitude: longitude)//GLLocation coordinates of displayment
        
        mapView.showsUserLocation = true
        centerMapOnLocation(location: homeLocation)
    }
    
    var homeLocation = CLLocation();
    let regionRadius: CLLocationDistance = 150//distance of zooooom
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
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
    
}
