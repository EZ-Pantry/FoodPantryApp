//
//  ApprovedUserViewCell.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 4/8/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class ApprovedUserViewCell: UITableViewCell {

    @IBOutlet var cellView: UIView!
    @IBOutlet var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
