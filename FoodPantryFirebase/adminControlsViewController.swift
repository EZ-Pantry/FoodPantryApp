//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
class adminControlsViewController: UIViewController {

    @IBOutlet weak var addItemsButton: UIButton!
    @IBOutlet weak var viewStatisticsButton: UIButton!
    @IBOutlet weak var editItemDataButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make buttons rounded below
        addItemsButton.layer.cornerRadius = 15//15px
        addItemsButton.clipsToBounds = true

        viewStatisticsButton.layer.cornerRadius = 15
        viewStatisticsButton.clipsToBounds = true
        
        editItemDataButton.layer.cornerRadius = 15
        editItemDataButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    

    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
