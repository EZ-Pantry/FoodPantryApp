//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseDatabase
class adminQRViewController: UIViewController {

    var PantryName = ""
    var ref: DatabaseReference!
    var alert = LoadingBar()
    var foodPantryQRText = ""
    
    @IBOutlet var test: UIImageView!
    @IBOutlet weak var saveQRButton: UIButton!
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet var generateButton: UIButton!
    
    
    //barcodes will be 8 numbers long - random numbers, 1-9
    
    var imageName: UIImage = UIImage()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        //we set pantry code
        PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        saveQRButton.layer.cornerRadius = 15
        saveQRButton.clipsToBounds = true
        
        generateButton.layer.cornerRadius = 15
        generateButton.clipsToBounds = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        updateCode()
    }
    
    func updateCode() {
        let myGroup = DispatchGroup()
            
        alert.showLoadingAlert()
        myGroup.enter()
            self.retreiveQRTextFromFirebase(callback: {(success, QRText)-> Void in
             
             if(success) {
                //do creation of QR
                self.generateCodeFromString(text: QRText)
                myGroup.leave()
             } else {
                RequestError().showError()
            }
            
         })
        
        myGroup.notify(queue: .main) {
            self.alert.hideLoadingAlert()
        }
    }
    
    func generateCodeFromString(text: String) -> Void{

        let id:String = text

        let ciImageFromQRCode = BarcodeGenerator.generateQRCodeFromString(id)

        // Scale according to imgViewQRCode. So, image is not blurred.
        let scaleX = (QRCodeImageView.frame.size.width / ciImageFromQRCode.extent.size.width)
        let scaleY = (QRCodeImageView.frame.size.height / ciImageFromQRCode.extent.size.height)

        let imgTransformed = ciImageFromQRCode.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        self.QRCodeImageView.image = BarcodeGenerator.convert(imgTransformed)
        self.imageName = BarcodeGenerator.convert(imgTransformed)

    }
    
        
    func retreiveQRTextFromFirebase(callback: @escaping (_ success: Bool,_ location: String)-> Void) {
        ref.child(PantryName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
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
    
    
    
    @IBAction func saveQrButtonTapped(_ sender: UIButton) {
        //save the image of the barcode to camera roll
        //saveBarcode()
        share(image: imageName)
    }
    
    
    func saveBarcode() {
        UIImageWriteToSavedPhotosAlbum(imageName, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print(error)
        } else {
            let alert = UIAlertController(title: "Barcode Image Saved", message: "Go to your Camera Roll", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    @IBAction func generateNew(_ sender: Any) {
        
        var newCode = ""
        
        for _ in 0..<6 {
            newCode += String(Int.random(in: 1 ..< 10))
        }
        
        //update firebase
        self.ref.child(self.PantryName).child("Food Pantry QR Text").setValue(newCode);
        updateCode()
        
    }
    
    //https://www.hackingwithswift.com/example-code/uikit/how-to-print-using-uiactivityviewcontroller
    func share(image: UIImage) {
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true)
    }
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}

class BarcodeGenerator {
    
    class func generateQRCodeFromString(_ strQR:String) -> CIImage {
        let dataString = strQR.data(using: String.Encoding.isoLatin1)

        let qrFilter = CIFilter(name:"CICode128BarcodeGenerator")
        qrFilter?.setValue(dataString, forKey: "inputMessage")
        return (qrFilter?.outputImage)!
    }


    class func convert(_ cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
}
