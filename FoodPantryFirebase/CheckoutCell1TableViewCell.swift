//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit

class CheckoutCell1TableViewCell: UITableViewCell {

    
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var foodTitle: UILabel!
    @IBOutlet var foodQuantity: UILabel!
    
    @IBOutlet var deleteButton: UIButton!
    
    var tapCallback: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func deleteItem(_ sender: Any) {
         tapCallback?()
    }
    
    //https://fluffy.es/handling-button-tap-inside-uitableviewcell-without-using-tag/
    
}


