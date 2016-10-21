//
//  ArchivePopOverViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-25.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

protocol ArchivePopOverViewControllerDelegate {
    func archiveItemReturned(value: ScannedItem)
}

class ArchivePopOverViewController: UIViewController {
    
    var platePickerView = UIPickerView()
    var freezerLocationPickerView = UIPickerView()
    var freezerLocation = ["F":"", "S":"", "R":""]
    var plateState = true
    var scannedBarcode = ""
    var scannedItem : ScannedItem!
    var curentUser : CurentUser!
    var delegate : ArchivePopOverViewControllerDelegate!
    var topViewController : UIViewController?
    enum device {
        case iPhone6plus
        case iPhone6
        case iPhone5
        case iPhone4
    }
    var curentDevice: device!
    
    var containerViewVerticalSpacing: CGFloat!
    var containerViewHeight: CGFloat!
    var itemsDetailsHeight: CGFloat!
    var scrollViewHeight: CGFloat!
    var scrollViewContentToScrollViewBottomHeight: CGFloat!
    var productHeightChange: CGFloat!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var libraryNameTextField: UITextField!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var detailedInformationTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var expieryDate: UITextField!
    @IBOutlet weak var freezerLocationTextField: UITextField!
    @IBOutlet weak var itemType: UISegmentedControl!
    @IBOutlet weak var plateType: UISegmentedControl!
    @IBOutlet weak var plateStatus: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var scrollViewContentToScrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemsDetailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalInformationVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var freezerLocationVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var expiryDateVerticalSpacingConstraint: NSLayoutConstraint!
    @IBAction func itemTypeChanged(sender: AnyObject) {
        view.endEditing(true)
//        self.view.layoutIfNeeded()
        if itemType.selectedSegmentIndex == 0 {
            showPlatelayout()
            plateState = true
            resetContent()
        } else {
            showProductLayout()
            plateState = false
            resetContent()
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func ok(sender: AnyObject) {
        scannedItem = ScannedItem()
        if plateState {
            scannedItem.barcode = scannedBarcode
            scannedItem.creatorFirstName = curentUser.firstName
            scannedItem.creatorLastName = curentUser.lastName
            scannedItem.creatorUsername = curentUser.username
            scannedItem.dateCreated = dateTextField.text!
            scannedItem.detailedInformation = detailedInformationTextField.text!
            scannedItem.library = libraryNameTextField.text!
            scannedItem.name = nameTextField.text!
            scannedItem.project = projectNameTextField.text!
            scannedItem.type = itemType.selectedSegmentIndex == 0 ? "Plate" : "Product"
            scannedItem.plateType = plateType.selectedSegmentIndex == 0 ? "384" : "96"
            scannedItem.plateStatus = plateStatus.selectedSegmentIndex == 0 ? "Original" : "Replicate"
            delegate.archiveItemReturned(scannedItem)
        } else {
            scannedItem.barcode = scannedBarcode
            scannedItem.creatorFirstName = curentUser.firstName
            scannedItem.creatorLastName = curentUser.lastName
            scannedItem.creatorUsername = curentUser.username
            scannedItem.dateCreated = dateTextField.text!
            scannedItem.expiryDate = expieryDate.text!
            scannedItem.detailedInformation = detailedInformationTextField.text!
            scannedItem.name = nameTextField.text!
            scannedItem.type = itemType.selectedSegmentIndex == 0 ? "Plate" : "Product"
            delegate.archiveItemReturned(scannedItem)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = scannedBarcode
        expieryDate.alpha = 0
        adjusTheFrames()
        setTextfieldDelegates()
        setUpDateTextFieldsInputView()
        setUpExpiryDateTextFieldsInputView()
        setUpFreezerLocationTextFieldsInputView()
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        okButton.layer.borderWidth = 1
        okButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        okButton.enabled = false
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
    }
    func adjusTheFrames() {
        switch view.frame.size.height {
        case 736:
            fallthrough
        case 667:
            curentDevice = .iPhone6
            containerViewHeight = 430
            itemsDetailsHeight = 290
            scrollViewHeight = 290
            scrollViewContentToScrollViewBottomHeight = 0
            productHeightChange = 110
            let parentVC = MainViewController()
            containerViewVerticalSpacing = parentVC.topBarHeight
        case 568:
            fallthrough
        default:
            curentDevice = .iPhone4
            containerViewHeight = 380
            itemsDetailsHeight = 290
            scrollViewHeight = 240
            scrollViewContentToScrollViewBottomHeight = 10
            productHeightChange = 95
            containerViewVerticalSpacing = 40
        }
        containerViewHeightConstraint.constant = containerViewHeight
        itemsDetailsHeightConstraint.constant = itemsDetailsHeight
        scrollViewHeightConstraint.constant = scrollViewHeight
        scrollViewContentToScrollViewBottomConstraint.constant = scrollViewContentToScrollViewBottomHeight
        containerViewVerticalSpacingConstraint.constant = containerViewVerticalSpacing
        scrollView.contentSize = CGSize(width: self.view.frame.size.width - (2 * 16), height: itemsDetailsHeight)
        self.view.layoutIfNeeded()
    }
    func resetContent() {
        nameTextField.text = ""
        libraryNameTextField.text = ""
        projectNameTextField.text = ""
        freezerLocationTextField.text = ""
        dateTextField.text = ""
        detailedInformationTextField.text = ""
        expieryDate.text = ""
        plateType.selectedSegmentIndex = 0
        plateStatus.selectedSegmentIndex = 0
        okButton.enabled = false
    }
    func showPlatelayout() {
        UIView.animateWithDuration(1.0) {
            self.libraryNameTextField.alpha = 1
            self.projectNameTextField.alpha = 1
            self.plateType.alpha = 1
            self.plateStatus.alpha = 1
            self.expieryDate.alpha = 0
            self.nameTextField.placeholder = "Plate Name > 4 characters"
            self.containerViewHeightConstraint.constant = self.containerViewHeight
            self.itemsDetailsHeightConstraint.constant = self.itemsDetailsHeight
            self.scrollViewHeightConstraint.constant = self.scrollViewHeight
            self.scrollView.contentSize.height = self.scrollViewHeight
            self.freezerLocationVerticalSpacingConstraint.constant = 75
            self.view.layoutIfNeeded()
        }
    }
    func showProductLayout() {
        UIView.animateWithDuration(1.0) {
            self.libraryNameTextField.alpha = 0
            self.projectNameTextField.alpha = 0
            self.plateType.alpha = 0
            self.plateStatus.alpha = 0
            self.expieryDate.alpha = 1
            self.nameTextField.placeholder = "Product Name"
            self.containerViewHeightConstraint.constant -= self.productHeightChange
            self.itemsDetailsHeightConstraint.constant -= self.productHeightChange
            self.freezerLocationVerticalSpacingConstraint.constant = 5
            self.scrollViewHeightConstraint.constant -= self.productHeightChange
            self.scrollView.contentSize.height -= self.productHeightChange
            self.view.layoutIfNeeded()
            
        }
    }
    func setUpFreezerLocationTextFieldsInputView() {
        freezerLocationPickerView.dataSource = self
        freezerLocationPickerView.delegate = self
        freezerLocationPickerView.frame = CGRectMake(0, 40, view.bounds.width, 100)
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 140))
        inputView.backgroundColor = .lightGrayColor()
        
        inputView.addSubview(freezerLocationPickerView) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRectMake(0, 0, view.bounds.width, 40))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(ArchivePopOverViewController.freezerLocationPickerViewDoneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        freezerLocationTextField.inputView = inputView
    }
    
    func setUpDateTextFieldsInputView() {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 140))
        inputView.backgroundColor = .lightGrayColor()
        let datePickerView:UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, view.bounds.width, 100))
        datePickerView.datePickerMode = UIDatePickerMode.Date
        inputView.addSubview(datePickerView)
        let doneButton = UIButton(frame: CGRectMake(0, 0, view.bounds.width/2, 40))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(ArchivePopOverViewController.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        let todaysDate = UIButton(frame: CGRectMake(view.bounds.width/2, 0, view.bounds.width/2, 40))
        todaysDate.setTitle("Today", forState: UIControlState.Normal)
        todaysDate.setTitle("Today", forState: UIControlState.Highlighted)
        todaysDate.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        todaysDate.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        todaysDate.addTarget(self, action: #selector(ArchivePopOverViewController.todaysDate(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        inputView.addSubview(todaysDate) // add Button to UIView
        dateTextField.inputView = inputView
        datePickerView.addTarget(self, action: #selector(ArchivePopOverViewController.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    func setUpExpiryDateTextFieldsInputView() {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 140))
        inputView.backgroundColor = .lightGrayColor()
        let datePickerView:UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, view.bounds.width, 100))
        datePickerView.datePickerMode = UIDatePickerMode.Date
        inputView.addSubview(datePickerView)
        let doneButton = UIButton(frame: CGRectMake(0, 0, view.bounds.width, 40))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        inputView.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(ArchivePopOverViewController.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        expieryDate.inputView = inputView
        datePickerView.addTarget(self, action: #selector(ArchivePopOverViewController.handleExpiryDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    func handleExpiryDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        expieryDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func doneButton(sender:UIButton) {
        view.endEditing(true)
    }
    func todaysDate(sender:UIButton){
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = dateFormatter.stringFromDate(date)
        dateTextField.resignFirstResponder()
    }
    func freezerLocationPickerViewDoneButton(sender:UIButton) {
        if freezerLocation["F"] != "" && freezerLocation["S"] != "" && freezerLocation["R"] != "" {
            self.freezerLocationTextField.text = freezerLocation["F"]!+freezerLocation["S"]!+freezerLocation["R"]!
        }
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ArchivePopOverViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 16
        case 1:
            return 6
        default:
            return 5
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return row == 0 ? "Freezer" : "F\(String(format: "%02d", row))"
        case 1:
            return row == 0 ? "Shelf" : "S\(String(format: "%02d", row))"
        default:
            return row == 0 ? "Rack" : "R\(String(format: "%02d", row))"
        }
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            switch component {
            case 0:
                freezerLocation.updateValue("F\(String(format: "%02d", row))", forKey: "F")
            case 1:
                freezerLocation.updateValue("S\(String(format: "%02d", row))", forKey: "S")
            default:
                freezerLocation.updateValue("R\(String(format: "%02d", row))", forKey: "R")
            }
        }
    }
}
extension ArchivePopOverViewController : UITextFieldDelegate {
    
    func setTextfieldDelegates() {
        nameTextField.delegate = self
        libraryNameTextField.delegate = self
        projectNameTextField.delegate = self
        freezerLocationTextField.delegate = self
        dateTextField.delegate = self
        detailedInformationTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            plateState ? libraryNameTextField.becomeFirstResponder() : freezerLocationTextField.becomeFirstResponder()
        case libraryNameTextField:
            projectNameTextField.becomeFirstResponder()
        case projectNameTextField:
            freezerLocationTextField.becomeFirstResponder()
        case freezerLocationTextField:
            dateTextField.becomeFirstResponder()
        case detailedInformationTextField:
            detailedInformationTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == detailedInformationTextField && plateState{
            UIView.animateWithDuration(1.0, animations: {
                self.containerViewVerticalSpacingConstraint.constant = self.containerViewVerticalSpacing
                self.view.layoutIfNeeded()
            })
        }
        // Checking the length of each of the specified textFields. Purpose is to let user know why Ok buttom in not being enabled.
        switch textField {
        case nameTextField:
            checkTextFieldLength(textField)
        case libraryNameTextField:
            checkTextFieldLength(textField)
        case projectNameTextField:
            checkTextFieldLength(textField)
        default:
            break
        }
        if plateState {
            UIView.animateWithDuration(0.5) {
                self.containerViewHeightConstraint.constant += 100.0
                self.scrollViewHeightConstraint.constant += 100.0
                self.view.layoutIfNeeded()
            }
        }
        
        okButton.enabled = plateState ? (nameTextField.text?.characters.count > 4 && libraryNameTextField.text?.characters.count > 4 &&  projectNameTextField.text?.characters.count > 4 && dateTextField.text != "" && freezerLocationTextField.text != "") : (nameTextField.text?.characters.count > 4 && dateTextField.text != "" && freezerLocationTextField.text != "")
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        if plateState {
            UIView.animateWithDuration(0.5) {
                self.containerViewHeightConstraint.constant -= 100.0
                self.scrollViewHeightConstraint.constant -= 100.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func checkTextFieldLength(textField: UITextField) {
        if textField.text?.characters.count < 5 {
            shake(textField)
            textField.textColor = .redColor()
            let tempStoredText = textField.text
            textField.text = "\"\(tempStoredText!)\" is less than 5 characters"
            pause(seconds: 2.0, completion: {
                textField.textColor = .blackColor()
                textField.text = tempStoredText
            })
        }
    }
}

