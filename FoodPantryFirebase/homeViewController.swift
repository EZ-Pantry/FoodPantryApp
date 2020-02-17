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

    @IBOutlet weak var welcomeNameLbl: UILabel!
//    @IBOutlet weak var mapView: MKMapView!
//    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //map config below
//        locationManager.requestWhenInUseAuthorization();
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locationManager.distanceFilter = kCLDistanceFilterNone;
//        locationManager.startUpdatingLocation();
//        
//        mapView.showsUserLocation = true;
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
          self.welcomeNameLbl.text = "Welcome, \(fullName)"
            
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
    
}
