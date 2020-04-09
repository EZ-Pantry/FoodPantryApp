//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
class adminControlsViewController: UIViewController {

    @IBOutlet weak var addItemsButton: UIButton!
    @IBOutlet weak var viewStatisticsButton: UIButton!
    @IBOutlet weak var editItemDataButton: UIButton!
    @IBOutlet weak var foodPantryBarcodeButton: UIButton!
    @IBOutlet var otherButton: UIButton!
    @IBOutlet var notificationsButton: UIButton!
    @IBOutlet var manageUsersButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make buttons rounded below
        addItemsButton.layer.cornerRadius = 15//15px
        addItemsButton.clipsToBounds = true
        
        addItemsButton.titleLabel?.minimumScaleFactor = 0.5
        addItemsButton.titleLabel?.numberOfLines = 1;
        addItemsButton.titleLabel?.adjustsFontSizeToFitWidth = true

        viewStatisticsButton.layer.cornerRadius = 15
        viewStatisticsButton.clipsToBounds = true
        
        viewStatisticsButton.titleLabel?.minimumScaleFactor = 0.5
        viewStatisticsButton.titleLabel?.numberOfLines = 1;
        viewStatisticsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        editItemDataButton.layer.cornerRadius = 15
        editItemDataButton.clipsToBounds = true
        
        editItemDataButton.titleLabel?.minimumScaleFactor = 0.5
        editItemDataButton.titleLabel?.numberOfLines = 1;
        editItemDataButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        foodPantryBarcodeButton.layer.cornerRadius = 15
        foodPantryBarcodeButton.clipsToBounds = true
        
        foodPantryBarcodeButton.titleLabel?.minimumScaleFactor = 0.5
        foodPantryBarcodeButton.titleLabel?.numberOfLines = 1;
        foodPantryBarcodeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        otherButton.layer.cornerRadius = 15
        otherButton.clipsToBounds = true
        
        otherButton.titleLabel?.minimumScaleFactor = 0.5
        otherButton.titleLabel?.numberOfLines = 1;
        otherButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        notificationsButton.layer.cornerRadius = 15
        notificationsButton.clipsToBounds = true
        
        notificationsButton.titleLabel?.minimumScaleFactor = 0.5
        notificationsButton.titleLabel?.numberOfLines = 1;
        notificationsButton.titleLabel?.adjustsFontSizeToFitWidth = true

        
        manageUsersButton.layer.cornerRadius = 15
        manageUsersButton.clipsToBounds = true
        
        manageUsersButton.titleLabel?.minimumScaleFactor = 0.5
        manageUsersButton.titleLabel?.numberOfLines = 1;
        manageUsersButton.titleLabel?.adjustsFontSizeToFitWidth = true

        // Do any additional setup after loading the view.
    }

    

    

}
