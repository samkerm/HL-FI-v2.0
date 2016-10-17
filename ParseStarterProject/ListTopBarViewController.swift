//
//  ListTopBarViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-26.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ListTopBarViewController: UIViewController {

    var height = CGFloat()
    let text = UILabel()
    let backButton = UIButton()
    let submitButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let parentVC = MainViewController()
        height = parentVC.topBarHeight
        let topMargin: CGFloat = 10.0
        
        self.view.backgroundColor = .blackColor()
        
        text.frame = CGRect(x: 0.0, y: topMargin, width: self.view.frame.width, height: height)
        text.text = "Scanned Items"
        text.adjustsFontSizeToFitWidth = true
        text.textColor = .whiteColor()
        text.textAlignment = .Center
        self.view.addSubview(text)
        
        
        let backBImage = UIImage(named: "back")
        backButton.frame = CGRect(x: 20.0, y: (height/2 - backBImage!.size.height/2) + topMargin, width: backBImage!.size.width, height: backBImage!.size.height)
        backButton.setImage(backBImage, forState: .Normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        submitButton.setTitle("Submit", forState: .Normal)
        submitButton.setTitleColor(.whiteColor(), forState: .Normal)
        submitButton.setTitleColor(.darkGrayColor(), forState: .Highlighted)
        submitButton.frame = CGRect(x: (self.view.frame.width - height - 10), y: topMargin, width: height, height: height)
        submitButton.titleLabel?.font = UIFont(name: "helvetica", size: 10)
        submitButton.addTarget(self, action: #selector(submitButtonPressed), forControlEvents: .TouchUpInside)
        self.view.addSubview(submitButton)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submitButtonPressed() {
        if let listVC = self.parentViewController as? ListViewController {
            switch listVC.deviceModeIndex {
            case 1:
                listVC.parseHandler.addScannedItemsToDataBase(listVC.scannedItems, completion: { (success, error, index) in
                    if success && index == 0 {
                        listVC.scannedItems.removeAll()
                        listVC.delegate.listScannedItemsReturned(listVC.scannedItems)
                        if let listTableVC = listVC.childViewControllers.last as? ListTableViewController {
                            listTableVC.scannedItems = listVC.scannedItems
                            listTableVC.tableView.reloadData()
                            if listVC.scannedItems.isEmpty {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    } else {
                        print("Found error saving \(listVC.scannedItems[index]). All items before this have been saved. \(error).")
                        for i in 0..<index {
                            listVC.scannedItems.removeAtIndex(i)
                        }
                        listVC.delegate.listScannedItemsReturned(listVC.scannedItems)
                        if let listTableVC = listVC.childViewControllers.last as? ListTableViewController {
                            listTableVC.scannedItems = listVC.scannedItems
                            listTableVC.tableView.reloadData()
                        }
                    }

                })
            default:
                listVC.scannedItems = listVC.parseHandler.updateChanges(listVC.scannedItems, defrostingUser: listVC.curentUser)
                listVC.delegate.listScannedItemsReturned(listVC.scannedItems)
                if let listTableVC = listVC.childViewControllers.last as? ListTableViewController {
                    listTableVC.scannedItems = listVC.scannedItems
                    listTableVC.tableView.reloadData()
                    if listTableVC.scannedItems.isEmpty {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
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

}
