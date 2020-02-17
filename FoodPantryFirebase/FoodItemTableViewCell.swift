//
//  FoodItemTableViewCell.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/13/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class FoodItemTableViewCell: UITableViewCell {
    @IBOutlet weak var foodItemImageView: UIImageView!
    @IBOutlet weak var foodItemNameLbl: UILabel!
    @IBOutlet weak var foodItemCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        foodItemImageView?.translatesAutoresizingMaskIntoConstraints = false;
//        foodItemNameLbl?.translatesAutoresizingMaskIntoConstraints = false;
//        foodItemNameLbl?.translatesAutoresizingMaskIntoConstraints = false;
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
