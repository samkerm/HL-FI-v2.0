//
//  ProductScanSuccessViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-28.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProductScanSuccessViewController: UIViewController {

    var scannedItem : ScannedItem!
    
    @IBOutlet weak var successfulView: UIView!
    @IBOutlet weak var doneView: UIView!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfThawsLabel: UILabel!
    @IBOutlet weak var dateLastDefrostedLabel: UILabel!
    @IBOutlet weak var lastDefrostedByLabel: UILabel!
    @IBOutlet weak var creatorsNameLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var detailedInformationLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var detailedInformationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var successfullViewHeightConstraint: NSLayoutConstraint!
    @IBAction func doneButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        doneView.layer.cornerRadius = 20
        successfulView.layer.cornerRadius = 20
        if (scannedItem != nil) {
            barcodeLabel.text = scannedItem.barcode
            nameLabel.text = scannedItem.name
            numberOfThawsLabel.text = String(scannedItem.numberOfThaws)
            lastDefrostedByLabel.text = scannedItem.lastDefrostedBy
            dateLastDefrostedLabel.text = scannedItem.dateLastDefrosted
            creatorsNameLabel.text = scannedItem.creatorFirstName + " " + scannedItem.creatorLastName
            dateCreatedLabel.text = scannedItem.dateCreated
            expiryDateLabel.text = scannedItem.expiryDate
            detailedInformationLabel.text = scannedItem.detailedInformation
        }
        detailedInformationLabel.sizeToFit()
        let DILFrameHeight = min(detailedInformationLabel.frame.size.height, 86)
        detailedInformationLabel.frame.size.height = DILFrameHeight
        view.layoutIfNeeded()
        successfullViewHeightConstraint.constant += DILFrameHeight - 15
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
    }
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor.clearColor()
    }
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [], animations: {
            self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            }, completion: nil)
        view.layoutIfNeeded()
    }
    override func viewWillDisappear(animated: Bool) {
        self.view.backgroundColor = UIColor.clearColor()
    }

}
