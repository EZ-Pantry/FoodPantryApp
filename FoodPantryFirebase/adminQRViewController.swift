//
//  adminQRViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/16/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseDatabase
class adminQRViewController: UIViewController {

    var foodPantryName = ""
    var ref: DatabaseReference!
    var alert = LoadingBar()
    var foodPantryQRText = ""
    
    @IBOutlet weak var saveQRButton: UIButton!
    @IBOutlet weak var QRCodeImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        //we set pantry code
        foodPantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        saveQRButton.layer.cornerRadius = 15
        saveQRButton.clipsToBounds = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let myGroup = DispatchGroup()
            
        alert.showLoadingAlert()
        
        myGroup.notify(queue: .main) {
                                      
            self.retreiveQRTextFromFirebase(callback: {(success, QRText)-> Void in
             
             if(success) {
                //do creation of QR
                var imageName = self.generateBarcode(from: QRText)
                self.QRCodeImageView.image = imageName//display the barcode
             }
            
         })
        }
        self.alert.hideLoadingAlert()
    }
    
        
    func retreiveQRTextFromFirebase(callback: @escaping (_ success: Bool,_ location: String)-> Void) {
        ref.child(foodPantryName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print("got")
            let value = snapshot.value as? NSDictionary
            let foodPantryQRText = value?["Food Pantry QR Text"] as? String ?? "" //load in the admin code
            callback(true, foodPantryQRText)
        // ...
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
            callback(false, "")
        }
    }
    
    func generateBarcode(from string: String) -> UIImage? {
        //https://www.hackingwithswift.com/example-code/media/how-to-create-a-barcode
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    
    
    @IBAction func saveQrButtonTapped(_ sender: UIButton) {
        //save the image of the barcode to camera roll
        takeScreenShot();
        let alert = UIAlertController(title: "Barcode Image Saved", message: "Go to your Camera Roll to see the image!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
    }
    
    func takeScreenShot(){
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
        
    }
    

    @IBAction func dismissTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
