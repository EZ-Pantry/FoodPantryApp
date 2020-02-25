//
//  popUpViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/20/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class popUpViewController: UIViewController {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemNutritionalImage: UIImageView!
    @IBOutlet weak var popOverView: UIView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemQuantityLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setPopOverProperties();
        // Do any additional setup after loading the view.
    }
    
    func setPopOverProperties(){
        itemName.text = itemClickedName
        if(refreshOccurred){
            itemImage.load(url: URL(string: itemClickedImageURL)!);
        }
        else{
            itemImage.image = UIImage(named: itemClickedImageURL)
        }
        itemQuantityLbl.text = "Quantity: \(itemClickedQuantity)";
        
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
        dismiss(animated: true, completion: nil)
    }
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.itemImage.image = image
                    }
                }
            }
        }
    }
    

}
