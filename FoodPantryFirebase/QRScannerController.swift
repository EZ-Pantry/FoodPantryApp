//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Ashay Parikh on 2/8/20.
//  Copyright © 2020 Ashay Parikh. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel! //message at the bottom of the screen
    @IBOutlet var topbar: UIView! //message at the top of the screen
    
    //code for capturing a live stream using the camera
    var captureSession:AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var sent:Bool = false //if the barcode has been sent to the next view
    
    private var code:String = "" //barcode
    
    var checkedOut = "" //previous checked out items, data is transferred between views: QRScanner, QRScrape, QRCodeView
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Do any additional setup after loading the view.

        // Get the back-facing camera for capturing videos
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
                self.performSegue(withIdentifier: "GoToScrape", sender: self)
                sent = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToScrape"{ //go to the scrapecontroller
            let destinationVC = segue.destination as? QRScrapeController
            destinationVC?.barcode = code //send the code
            destinationVC?.quantity = "1" //send the quantity of items (default)
            destinationVC?.checkedOut = checkedOut //send the current items checkout out
        }
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
        print("yes")
        dismiss(animated: true, completion: nil)
    }
    
    

}
