//
//  adminAddImageManualViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 4/2/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import WebKit
var newImageURL = ""

class adminAddImageManualViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var noButton: UIButton!
    var activeField: UITextField!
    
    var imageSRCData: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        yesButton.layer.cornerRadius = 15//15px
        yesButton.clipsToBounds = true
        
        yesButton.titleLabel?.minimumScaleFactor = 0.5
        yesButton.titleLabel?.numberOfLines = 1;
        yesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        noButton.layer.cornerRadius = 15//15px
        noButton.clipsToBounds = true
        
        noButton.titleLabel?.minimumScaleFactor = 0.5
        noButton.titleLabel?.numberOfLines = 1;
        noButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
        print("food beloww")
        print(foodItemEnteringName)
//        https://www.google.com/search?tbm=isch&as_q=vienna&tbs=isch
//        https://www.google.com/search?tbm=isch&as_q=vienna&tbs=isz:lt,islt:4mp,sur:fmc
        let url = URL(string: "https://www.google.com/search?tbm=isch&as_q=" + foodItemEnteringName + "&tbs=isch")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response , error) in
            
            if error != nil{
                print(error)
            }
            else{
                let htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)//the HTML
                print(htmlContent)
                //next 99 characters
                
            }
        
        }
        task.resume()
        // Do any additional setup after loading the view.
    }
    


    @IBAction func yesButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        
    }
    

    
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
