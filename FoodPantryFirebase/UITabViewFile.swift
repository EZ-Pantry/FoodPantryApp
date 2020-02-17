//
//  UITabViewFile.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/10/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import Foundation
import UIKit
class CustomHeightTabBar : UITabBar {
    
       @IBInspectable var height: CGFloat = 0.0

       override func sizeOfTab(_ size: CGSize) -> CGSize {
           var sizeOfTab = super.sizeOfTab(size)
           if height > 0.0 {
               sizeOfTab.height = height
           }
           return sizeOfTab
       }
   }
