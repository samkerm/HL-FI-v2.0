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
    let targetView = UIView()
    let line = UIView()
    var scanmode = false
    
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
        drawTargetRectangle(UIColor.whiteColor())
        view.addSubview(targetView)
        line.frame = CGRect.zero
        line.backgroundColor = .greenColor()
        view.addSubview(line)
        initialInstructions()
    }
    
    func drawTargetRectangle(color: UIColor) {
        targetView.layer.sublayers?.removeAll()
        targetView.frame = CGRect(x: 0.0, y: view.frame.height/2 - 40.0, width: view.frame.width, height: 80.0)
        let rectTopPoints = [CGPoint(x: 20.0, y: 20.0),
                          CGPoint(x: 20.0, y: 0.0), // controlPoints 1&2
                          CGPoint(x: 40.0, y: 0.0),
                          CGPoint(x: view.frame.width - 30.0, y: 0.0),
                          CGPoint(x: view.frame.width - 20.0, y: 0.0), // controlPoints 1&2
                          CGPoint(x: view.frame.width - 20.0, y: 20.0)]
        let rectBottomPoints = [CGPoint(x: 20.0, y: 60.0),
                          CGPoint(x: 20.0, y: 80.0), // controlPoints 1&2
                          CGPoint(x: 30.0, y: 80.0),
                          CGPoint(x: view.frame.width - 30.0, y: 80.0),
                          CGPoint(x: view.frame.width - 20.0, y: 80.0), // controlPoints 1&2
                          CGPoint(x: view.frame.width - 20.0, y: 60.0)]
        
        let topBarPath = UIBezierPath()
        topBarPath.moveToPoint(rectTopPoints[0])
        topBarPath.addCurveToPoint(rectTopPoints[2], controlPoint1: rectTopPoints[1], controlPoint2: rectTopPoints[1])
        topBarPath.addLineToPoint(rectTopPoints[3])
        topBarPath.addCurveToPoint(rectTopPoints[5], controlPoint1: rectTopPoints[4], controlPoint2: rectTopPoints[4])
        topBarPath.addClip()
        let topBarShape = CAShapeLayer()
        topBarShape.path = topBarPath.CGPath
        topBarShape.lineWidth = 2
        topBarShape.strokeColor = color.CGColor
        topBarShape.fillColor = UIColor.clearColor().CGColor
        targetView.layer.addSublayer(topBarShape)
        
        let bottomBarPath = UIBezierPath()
        bottomBarPath.moveToPoint(rectBottomPoints[0])
        bottomBarPath.addCurveToPoint(rectBottomPoints[2], controlPoint1: rectBottomPoints[1], controlPoint2: rectBottomPoints[1])
        bottomBarPath.addLineToPoint(rectBottomPoints[3])
        bottomBarPath.addCurveToPoint(rectBottomPoints[5], controlPoint1: rectBottomPoints[4], controlPoint2: rectBottomPoints[4])
        bottomBarPath.addClip()
        let bottomBarShape = CAShapeLayer()
        bottomBarShape.path = bottomBarPath.CGPath
        bottomBarShape.lineWidth = 2
        bottomBarShape.strokeColor = color.CGColor
        bottomBarShape.fillColor = UIColor.clearColor().CGColor
        targetView.layer.addSublayer(bottomBarShape)
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
        captureButton.enabled = false
        dimmedView.frame = view.frame
        dimmedView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        dimmedView.tag = 1001
        view.addSubview(dimmedView)
        let textCenter = CGPoint(x: dimmedView.bounds.width/2 - 50, y: dimmedView.bounds.height - 120)
        let text = UILabel(frame: CGRect(origin: textCenter, size: CGSize(width: 100, height: 100)))
        text.text = "Hold"
        text.textAlignment = .Center
        text.font = UIFont(name: "System-Regular", size: 17.0)
        text.textColor = .whiteColor()
        dimmedView.addSubview(text)
        UIView.animateWithDuration(1, delay: 2, options: [.CurveEaseOut, .AllowUserInteraction], animations: {
            text.alpha = 0
            self.dimmedView.alpha = 0
            }, completion: { (_) in
                text.removeFromSuperview()
                self.dimmedView.removeFromSuperview()
                self.captureButton.enabled = true
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
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            let barCodeObject = previewLayer!.transformedMetadataObjectForMetadataObject(readableObject)
            self.drawLine(barCodeObject!.bounds)
            pause(seconds: 1.0, completion: {
                if self.scanmode {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.foundCode(readableObject.stringValue)
                    self.line.frame = CGRect.zero
                    self.scanmode = false
                }
            })
        }
    }
    
    func foundCode(code: String) {
        if let mainVC = self.parentViewController as? MainViewController {
            mainVC.popUpInformation(code)
        }
    }
    
    func touchDown(){
        scanmode = true
        captureButton.alpha = 0.2
        drawTargetRectangle(UIColor.redColor())
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
        scanmode = false
        line.frame = CGRect.zero
        captureButton.alpha = 1
        captureSession.removeOutput(metadataOutput)
        drawTargetRectangle(UIColor.whiteColor())
    }
    
    func drawLine(bound: CGRect) {
        line.frame = bound
        line.frame.size.height = 2.0
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


