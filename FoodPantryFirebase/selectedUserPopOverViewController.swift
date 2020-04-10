//
//  selectedUserPopOverViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/10/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class selectedUserPopOverViewController: UIViewController {

    @IBOutlet weak var popOverView: UIView!
    var userName = ""
    var userEmail = ""
    var userLastDateVisited = ""
    var userLastItemCheckedOut = ""
    var userTotalItemsCheckedOut = ""
    var userID = ""
    
    @IBOutlet weak var userNameLbl: UILabel!

    @IBOutlet weak var userEmailLbl: UILabel!

    @IBOutlet weak var lastTimeVisitedLbl: UILabel!
    
    @IBOutlet weak var lastItemCheckedOutLbl: UILabel!
    
    @IBOutlet weak var totalItemsCheckedOut: UILabel!
    
    @IBOutlet weak var usserIDLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popOverView.layer.cornerRadius = 15
        popOverView.clipsToBounds = true
        
        userNameLbl.text = userName
        userEmailLbl.text = "Email: \(userEmail)"
        usserIDLbl.text = "ID: \(userID)"
        lastTimeVisitedLbl.text = "Last Date Visited: \(userLastDateVisited)"
        lastItemCheckedOutLbl.text = "Last Item Checked Out: \(userLastItemCheckedOut)"
        totalItemsCheckedOut.text = "Total Items Checked Out: \(userTotalItemsCheckedOut)"
        
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //as anothe way of dismissing the view, outside the view
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if !popOverView.frame.contains(location) {
            print("Tapped outside the view")
            dismiss(animated: true, completion: nil)
        }else {
            print("Tapped inside the view")
        }
    }
    
    @IBAction func dismissToSearchView(_ sender: UIButton) {
        print("clicked")
        dismiss(animated: true, completion: nil)
    }

}
