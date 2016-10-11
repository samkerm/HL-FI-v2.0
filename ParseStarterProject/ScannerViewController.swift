//
//  ScannerViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-25.
//  Copyright © 2016 Sam Kheirandish. All rights reserved.
//

import UIKit

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoOrientation : AVCaptureVideoOrientation!
    let metadataOutput = AVCaptureMetadataOutput()
    var captureButton = UIButton()
    let dimmedView = UIView()
    
    
    
    //-------------------------------------------------------------------------------------------------------------
    //      MARK: APEARANCE
    //-------------------------------------------------------------------------------------------------------------
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.running == false) {
            captureSession.startRunning();
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        addCaptureSession()
        addPreviewLayer()
        addCaptureButton()
        drawTargetRectangle()
        initialInstructions()
    }
    
    func drawTargetRectangle() {
        let square = CGRect(x: view.frame.width/2 - 75, y: view.frame.height/2 - 75, width: 150, height: 150)
        let rectangle = CGRect(x: 10, y: view.frame.height/2 - 40, width: view.frame.width - 20, height: 80)
        let pathS = UIBezierPath(rect: square)
        let shapeS = CAShapeLayer()
        shapeS.path = pathS.CGPath
        shapeS.lineWidth = 2
        shapeS.lineDashPattern = [4,10,1,2]
        shapeS.strokeColor = UIColor.redColor().CGColor
        shapeS.fillColor = UIColor.clearColor().CGColor
        let pathR = UIBezierPath(rect: rectangle)
        let shapeR = CAShapeLayer()
        shapeR.path = pathR.CGPath
        shapeR.lineWidth = 4
        shapeR.lineDashPattern = [10,30]
        shapeR.strokeColor = UIColor.redColor().CGColor
        shapeR.fillColor = UIColor.clearColor().CGColor
        view.layer.addSublayer(shapeS)
        view.layer.addSublayer(shapeR)
    }

    func addCaptureButton() {
        let buttonCenter = CGPoint(x: view.bounds.width/2 - 50, y: view.bounds.height - 120)
        let arcCenter = CGPoint(x: view.bounds.width/2, y: view.bounds.height - 70)
        let buttonFrame = CGRect(origin: buttonCenter, size: CGSize(width: 100, height: 100))
        let path = UIBezierPath(arcCenter: arcCenter, radius: CGFloat(60), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor.grayColor().CGColor
        shapeLayer.lineWidth = 7.0
        view.layer.addSublayer(shapeLayer)
        captureButton = UIButton(frame: buttonFrame)
        captureButton.layer.cornerRadius = captureButton.layer.frame.width/2
        captureButton.backgroundColor = .redColor()
        view.addSubview(captureButton)
        captureButton.addTarget(self, action: #selector(ScannerViewController.touchDown), forControlEvents: UIControlEvents.TouchDown)
        captureButton.addTarget(self, action: #selector(ScannerViewController.buttonReleased), forControlEvents: UIControlEvents.TouchUpInside)
        view.bringSubviewToFront(captureButton)
    }
    
    func addPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: UIApplication.sharedApplication().statusBarFrame.size.height
            , width: view.frame.width, height: view.frame.height)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.position = CGPointMake(self.view.bounds.width/2, view.frame.height/2 + 20)
        previewLayer.rectForMetadataOutputRectOfInterest(CGRect(x: 10, y: view.frame.height/2 - 75, width: view.frame.width - 20, height: 150))
        view.layer.addSublayer(previewLayer)
    }
    
    func initialInstructions() {
        dimmedView.frame = view.frame
        dimmedView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        dimmedView.tag = 1001
        view.addSubview(dimmedView)
        let text = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height/2 - 25 , width: view.bounds.width, height: 50))
        text.text = "Hold red button to capture the barcode"
        text.textAlignment = .Center
        text.font = UIFont(name: "System-Regular", size: 17.0)
        text.textColor = .whiteColor()
        text.alpha = 0
        dimmedView.addSubview(text)
        UIView.animateWithDuration(1, delay: 0, options: [.CurveEaseIn, .AllowUserInteraction], animations: {
            text.alpha = 1
            }, completion: nil)
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 2
        animation.toValue = 1.0
        animation.duration = 0.2
        animation.beginTime = CACurrentMediaTime() + 1
        text.layer.addAnimation(animation, forKey: nil)
        UIView.animateWithDuration(3, delay: 2, options: [.AllowUserInteraction], animations: {
            text.frame.offsetInPlace(dx: 0, dy: 90)
            }, completion: nil)
        UIView.animateWithDuration(6, delay: 4, options: [.CurveEaseOut, .AllowUserInteraction], animations: {
            text.alpha = 0
            self.dimmedView.alpha = 0
            }, completion: { (_) in
                text.removeFromSuperview()
                self.dimmedView.removeFromSuperview()
        })
    }
    
    //------------------------------------------------------------------------------------------------------------
    //      MARK: FUNCTIONS
    //-------------------------------------------------------------------------------------------------------------
    
    func addCaptureSession() {
        captureSession = AVCaptureSession()
        let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundCode(readableObject.stringValue)
        }
    }
    
    func foundCode(code: String) {
        if let mainVC = self.parentViewController as? MainViewController {
            mainVC.popUpInformation(code)
        }
    }
    
    func touchDown(){
        captureButton.alpha = 0.2
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes =
                [AVMetadataObjectTypeQRCode,
                 AVMetadataObjectTypeEAN8Code,
                 AVMetadataObjectTypeUPCECode,
                 AVMetadataObjectTypeAztecCode,
                 AVMetadataObjectTypeEAN13Code,
                 AVMetadataObjectTypeCode39Code,
                 AVMetadataObjectTypeCode128Code]
        }
    }
    
    func buttonReleased() {
        captureButton.alpha = 1
        captureSession.removeOutput(metadataOutput)
    }
    
    //-------------------------------------------------------------------------------------------------------------
    //      MARK: Handeling Alerts
    //-------------------------------------------------------------------------------------------------------------
    
    func failed() { // THIS ALERT POPS UP WHEN THE DEVICE CAMERA IS NOT ENABLELED
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
        captureSession = nil
    }
}


