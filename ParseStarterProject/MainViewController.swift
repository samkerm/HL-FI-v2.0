//
//  ViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-25.
//  Copyright © 2016 Sam Kheirandish. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // All view instanses of controllers
    let menuWidth: CGFloat = (UIScreen.mainScreen().bounds.width/4) * 2.0
    let topBarHeight : CGFloat = 60.0
    let animationTime: NSTimeInterval = 0.5
    var isOpening = false
    
    
    //Child view controllers
    var menuViewController = SettingsTableTableViewController()
    var scannerViewController = ScannerViewController()
    let topbarViewController = TopBarViewController()
    
    //Data instanses
    let modesArray : [String] = ["View mode", "Archive mode", "Defrost mode", "Discharge mode"]
    var modeRefference = 0
    var deviceModeIndex = 0 {
        didSet{
            topbarViewController.mode = modesArray[deviceModeIndex]
            topbarViewController.updateTitle(modesArray[deviceModeIndex])
            topbarViewController.menuButtonPressed()
            if (deviceModeIndex == 1 || deviceModeIndex == 2) && (modeRefference == 1 || modeRefference == 2) {
                if modeRefference != deviceModeIndex {
                    scannedItems.removeAll()
                }
            }
            switch deviceModeIndex {
            case 1,2:
                topbarViewController.listButton.popToExistance = true
                topbarViewController.listButton.enabled = scannedItems.count > 0 ? true : false
            default:
                topbarViewController.listButton.popToExistance = false
            }
        }
        willSet {
            modeRefference = deviceModeIndex
        }
    }
    var scannedItem = ScannedItem()
    var scannedItems = [ScannedItem]() {
        didSet{
           topbarViewController.listButton.enabled = scannedItems.count > 0 ? true : false
        }
    }
    var curentUser = CurentUser()
    var scannedBarcode = ""
    
    //Backend data handler
    let parseBackendHandler = ParseBackendHandler()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        setNeedsStatusBarAppearanceUpdate()
        
        menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("menu") as! SettingsTableTableViewController
        menuViewController.view.frame = CGRect(x: -menuWidth, y: topBarHeight, width: menuWidth, height: view.frame.height)
        topbarViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: topBarHeight)
        
        addChildViewController(scannerViewController)
        view.addSubview(scannerViewController.view)
        scannerViewController.didMoveToParentViewController(self)
        
        addChildViewController(topbarViewController)
        view.addSubview(topbarViewController.view)
        topbarViewController.didMoveToParentViewController(self)
        
        addChildViewController(menuViewController)
        view.addSubview(menuViewController.view)
        menuViewController.didMoveToParentViewController(self)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGuesture))
        scannerViewController.view.addGestureRecognizer(tapGesture)
        
        setToPercent(0.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //-------------------------------------------------------------------------------------------------------------
    //      MARK: Guestures + Functions
    //-------------------------------------------------------------------------------------------------------------
    
    
    // Guesture recognizine a tap on the hamburger menu
    func handleTapGuesture(recognizer: UITapGestureRecognizer) {
        let isOpen = menuViewController.view.frame.origin.x == 0.0 ? true : false
        if isOpen {
            UIView.animateWithDuration(animationTime, animations: {
                self.setToPercent(0.0)
                if let topBarVC = self.childViewControllers[1] as? TopBarViewController {
                    topBarVC.spinMenuButton()
                }
                }, completion: {_ in
                    self.menuViewController.view.layer.shouldRasterize = false
            })
        }
        for subview in scannerViewController.view.subviews {
            if subview.tag == 1001 {
                subview.removeFromSuperview()
            }
        }
    }
    // Guesture recognizine a drag on the screen and trnslates to percentage
    func handleGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(recognizer.view!.superview!)
        var progress = translation.x / menuWidth * (isOpening ? 1.0 : -1.0)
        progress = min(max(progress, 0.0), 1.0)
        
        switch recognizer.state {
        case .Began:
            isOpening = menuViewController.view.frame.origin.x == 0.0 ? false: true
            menuViewController.view.layer.shouldRasterize = true
            menuViewController.view.layer.rasterizationScale =
                UIScreen.mainScreen().scale
        case .Changed:
            self.setToPercent(isOpening ? progress : (1.0 - progress))
        case .Ended: fallthrough
        case .Cancelled: fallthrough
        case .Failed:
            var targetProgress: CGFloat
            if (isOpening) {
                targetProgress = progress < 0.7 ? 0.0 : 1.0
            } else {
                targetProgress = progress < 0.7 ? 1.0 : 0.0
            }
            UIView.animateWithDuration(animationTime, animations: {
                self.setToPercent(targetProgress)
                }, completion: {_ in
                    self.menuViewController.view.layer.shouldRasterize = false
            })
        default: break
        }
    }
    
    
    
//-------------------------------------------------------------------------------------------------------------
//      MARK: APEARANCE
//-------------------------------------------------------------------------------------------------------------

    
    
    func toggleSideMenu() {
        let isOpen = menuViewController.view.frame.origin.x == 0.0 ? true : false
        let targetProgress: CGFloat = isOpen ? 0.0: 1.0

        UIView.animateWithDuration(animationTime, animations: {
            self.setToPercent(targetProgress)
            }, completion: { _ in
                self.menuViewController.view.layer.shouldRasterize = false
        })
    }
    
    func setToPercent(percent: CGFloat) {
        menuViewController.view.alpha = CGFloat(max(0.2, percent))
        menuViewController.view.frame.origin.x = -menuWidth + menuWidth * CGFloat(percent)
        scannerViewController.view.alpha = CGFloat(max(0.2, 1 - percent))
        let menuButton = topbarViewController.menuButton
        menuButton.layer.transform = rotateButton(percent)
    }
    
    func rotateButton(percent: CGFloat) -> CATransform3D {
        var identity = CATransform3DIdentity
        identity.m34 = -1.0/1000
        let angle = percent * 2 * CGFloat(M_PI)
        let rotationTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        return rotationTransform
    }
    
    
    
//-------------------------------------------------------------------------------------------------------------
//      MARK: Handeling Pop ups
//-------------------------------------------------------------------------------------------------------------
    
    
    
    func popUpInformation(barcode : String) {
        scannedBarcode = barcode
        switch deviceModeIndex {
        case 0:
            popUpViewInformation(barcode)
        case 1:
            PopUpArchiveAlert(barcode, message: "Would you like to add this to the archiving list?")
        case 2:
            popUpDefrostAlert(barcode, message: "Would you like to add this to the defrosting list?")
        default:
            popUpDischargeAlert(barcode, message: "Would you like to remove this item from database?")
        }
    }
    
    func popUpViewInformation (barcodeText: String) {
        parseBackendHandler.lookUpBarcode(barcodeText, completion: { (exists, error, returnedItem) in
            if exists {
                self.scannedItem = returnedItem
                switch self.scannedItem.type {
                case "Plate":
                    self.performSegueWithIdentifier("ShowPlateScanSuccessPopover", sender: self)
                default:
                    self.performSegueWithIdentifier("ShowProductScanSuccessPopover", sender: self)
                }
            } else {
                self.showText(error)
            }
        })
        scannerViewController.buttonReleased()
        scannerViewController.captureSession.startRunning()
    }
    
    func popUpDefrostAlert(barcodeText: String, message: String) {
        parseBackendHandler.lookUpBarcode(barcodeText) { (exists, error, returnedItem) in
            if exists {
                let ac = UIAlertController(title: barcodeText, message: message, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) in
                    self.scannerViewController.buttonReleased()
                    self.scannerViewController.captureSession.startRunning()
                }))
                ac.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
                    self.scannedItems.append(returnedItem)
                    self.showText("Success")
                    self.scannerViewController.buttonReleased()
                    self.scannerViewController.captureSession.startRunning()
                }))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                let ac = UIAlertController(title: "Oops!", message: "This barcode has not been registered in our inventory. Please register the barcode first before defrosting it.", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) in
                    self.scannerViewController.buttonReleased()
                    self.scannerViewController.captureSession.startRunning()
                }))
                self.presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    func PopUpArchiveAlert(barcodeText: String, message : String) {
        parseBackendHandler.lookUpBarcode(barcodeText) { (exists, error, returnedItem) in
            if exists {
                self.showText("Item already in database")
                self.scannerViewController.buttonReleased()
                self.scannerViewController.captureSession.startRunning()
            } else if !exists {
                self.performSegueWithIdentifier("ShowArchivePopover", sender: self)
                self.scannerViewController.buttonReleased()
                self.scannerViewController.captureSession.startRunning()
            }
        }
    }
    
    func popUpDischargeAlert(barcode : String, message : String) {
        let ac = UIAlertController(title: "Discharge?", message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "No", style: .Default, handler: { (_) in
            self.scannerViewController.buttonReleased()
            self.scannerViewController.captureSession.startRunning()
        }))
        ac.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
            self.parseBackendHandler.removeFromDatabase(barcode, completion: { (success, found, deleted) in
                if success {
                    self.showText("SUCCESS!\nFound: \(found)\nDeleted: \(deleted)")
                } else {
                    self.showText("Failed!\nFound: \(found)\nDeleted: \(deleted)")
                }
            })
            self.scannerViewController.buttonReleased()
            self.scannerViewController.captureSession.startRunning()
        }))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func showText(text : String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.font = UIFont(name: "System-Regular", size: 17.0)
        label.textColor = .whiteColor()
        label.alpha = 0
        label.sizeToFit()
        label.center = self.view.center
        view.addSubview(label)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            label.alpha = 1
            }, completion: nil)
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.5
        animation.toValue = 1.0
        animation.duration = 0.3
        animation.beginTime = CACurrentMediaTime() + 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        UIView.animateWithDuration(3, delay: 0.5, options: .CurveEaseOut, animations: {
            label.alpha = 0
            }, completion: { (_) in
                label.removeFromSuperview()
        })
        label.layer.addAnimation(animation, forKey: nil)
    }
    
    
    
//-------------------------------------------------------------------------------------------------------------
//      MARK: Handeling Segue
//-------------------------------------------------------------------------------------------------------------
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showList" {
            if let destinationVC = segue.destinationViewController as? ListViewController {
                destinationVC.comingFromMainVC = true
                destinationVC.scannedItems = self.scannedItems
                destinationVC.deviceModeIndex = self.deviceModeIndex
                destinationVC.curentUser = self.curentUser
                destinationVC.delegate = self
            }
        } else if segue.identifier == "ShowPlateScanSuccessPopover" {
            if let destinationVC = segue.destinationViewController as? PlateScanSuccessPopOverVC {
                destinationVC.scannedItem = self.scannedItem
            }
        } else if segue.identifier == "ShowProductScanSuccessPopover" {
            if let destinationVC = segue.destinationViewController as? ProductScanSuccessViewController {
                destinationVC.scannedItem = self.scannedItem
            }
        }else if segue.identifier == "ShowArchivePopover" {
            if let destinationVC = segue.destinationViewController as? ArchivePopOverViewController {
                destinationVC.curentUser = self.curentUser
                destinationVC.scannedBarcode = self.scannedBarcode
                destinationVC.delegate = self
            }
        }

    }
}

extension MainViewController : ArchivePopOverViewControllerDelegate {
    func archiveItemReturned(value: ScannedItem) {
        self.scannedItem = value
        self.scannedItems.append(self.scannedItem)
    }
}
extension MainViewController: ListViewControllerDelegate {
    func listScannedItemsReturned(value: [ScannedItem]) {
        self.scannedItems = value 
    }
}
