//
//  EditName.swift
//  FoodPantryFirebase
//
//  Created by Ashay Parikh on 3/30/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation


extension String {
    
    public func trimTitle() -> String {
        
        let comma: Int = self.indexDistance(of: ",") ?? -1 //get the index of the food item
        
        if(comma >= 1) {
            return self.substring(to: comma)
        }
        return self
        
    }
    
}
