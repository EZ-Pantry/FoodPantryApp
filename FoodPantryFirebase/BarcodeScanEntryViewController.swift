//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.



import UIKit
import AVFoundation
import FirebaseDatabase
class BarcodeScanEntryViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel! //message at the bottom of the screen
    @IBOutlet var topbar: UIView! //message at the top of the screen
    
    //code for capturing a live stream using the camera
    var captureSession:AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var sent:Bool = false //if the barcode has been sent to the next view
    
    var alert = LoadingBar()
    
    private var code:String = "" //barcode
    
    var checkedOut = "" //previous checked out items, data is transferred between views: QRScanner, QRScrape, QRCodeView
    
    var barcodes = ""
    
    var ref: DatabaseReference! //ref to db
    
    //all the supported types
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
    AVMetadataObject.ObjectType.code39,
    AVMetadataObject.ObjectType.code39Mod43,
    AVMetadataObject.ObjectType.code93,
    AVMetadataObject.ObjectType.code128,
    AVMetadataObject.ObjectType.ean8,
    AVMetadataObject.ObjectType.ean13,
    AVMetadataObject.ObjectType.aztec,
    AVMetadataObject.ObjectType.pdf417,
    AVMetadataObject.ObjectType.itf14,
    AVMetadataObject.ObjectType.dataMatrix,
    AVMetadataObject.ObjectType.interleaved2of5,
    AVMetadataObject.ObjectType.qr]
    
    var foodPantryName = ""
    var barcodeTextFromFirebase = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodPantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        ref = Database.database().reference()
//        // Do any additional setup after loading the view.

        // Get the back-facing camera for capturing videos
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let myGroup = DispatchGroup()
        
        myGroup.enter()
        self.retreiveQRTextFromFirebase(callback: {(success, QRTextFromFirebase)-> Void in
             
        if(success) {
            self.barcodeTextFromFirebase = QRTextFromFirebase;//the code retrieved from barcode
            self.startCameraSession();
            myGroup.leave()
        } else {
            RequestError().showError()
            }
            
         })
        myGroup.notify(queue: .main) {
            self.showMessage()
        }
    }
    
    func showMessage() {
        let alert = UIAlertController(title: "Please scan the Food Pantry's Code", message: "You need to verify that you are in the Food Pantry.", preferredStyle: .alert)
                                 
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        let top = UIApplication.topViewController()!

        
        top.present(alert, animated: true, completion: nil);
    }
    
    func retreiveQRTextFromFirebase(callback: @escaping (_ success: Bool,_ location: String)-> Void) {
        ref.child(foodPantryName).observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    func startCameraSession(){
        let deviceDiscoverySession = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession else {
            print("Failed to get the camera device")
            return
        }

        do {
                    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                    let input = try AVCaptureDeviceInput(device: captureDevice)

                    // Set the input device on the capture session.
                    captureSession.addInput(input)

                    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                    let captureMetadataOutput = AVCaptureMetadataOutput()
                    captureSession.addOutput(captureMetadataOutput)

                    // Set delegate and use the default dispatch queue to execute the call back
                    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

                } catch {
                    // If any error occurs, simply print it out and don't continue any more.
                    print(error)
                    return
                }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        // Start video capture.
        captureSession.startRunning()

        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        view.bringSubviewToFront(topbar)

        messageLabel.text = "Move the camera close to the barcode"

        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
        qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No code is detected"
            return
        }
    
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
        
            if metadataObj.stringValue != nil && !sent {
                messageLabel.text = metadataObj.stringValue
                code = metadataObj.stringValue!
                sent = true
                compareBarcodeInformation();
            }
        }
    }
    
    func compareBarcodeInformation(){
        //check if the entry code match hee
        if(code == barcodeTextFromFirebase){
            
            let time: String = TimeStamp().generateCurrentTimeStamp()
            UserDefaults.standard.set(time, forKey: "UserSession")
            
            let alert = UIAlertController(title: "Access to Food Pantry Checkout Granted", message: "Checkout items!", preferredStyle: .alert)
                                     
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                 self.performSegue(withIdentifier: "toCheckoutOptions", sender: self)//perform when okay tapped
            }))
            self.present(alert, animated: true, completion: nil);
            
        }
        else{
           let alert = UIAlertController(title: "Access to Food Pantry Checkout Denied", message: "Please Try Again!", preferredStyle: .alert)
                                     
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
            }))
            self.present(alert, animated: true, completion: nil);
            sent = false
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func dismissViewToBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    

}


extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
