//
//  ListTableViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-25.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    var scannedItems = [ScannedItem]() {
        didSet {
            if let listVC = self.parentViewController as? ListViewController {
                listVC.updateScannedItemsGlobally(self.scannedItems)
            }
        }
    }
    var deviceModeIndex : Int!
    var selectedRow = 0
    let parseHandler = ParseBackendHandler()
    var curentUser = CurentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .blackColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    func submitListWithAllChanges() {
        if deviceModeIndex == 2 {
            let ac = UIAlertController(title: "Update Changes?", message: "Are you sure you want to update these chagnes to the database?", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            ac.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
                self.scannedItems = self.parseHandler.updateChanges(self.scannedItems, defrostingUser: self.curentUser)
                self.tableView.reloadData()
//                self.updateLeftBarButtonItem()
            }))
            presentViewController(ac, animated: true, completion: nil)
        } else if deviceModeIndex == 1 {
            let ac = UIAlertController(title: "Archive?", message: "Are you sure you want to add this list of barcodes to the database?", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            ac.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
                self.parseHandler.addScannedItemsToDataBase(self.scannedItems, completion: { (success, error, index) in
                    if success && index == 0 {
                        self.scannedItems.removeAll()
                        self.tableView.reloadData()
//                        self.updateLeftBarButtonItem()
                    } else {
                        print("Found error saving \(self.scannedItems[index]). All items before this have been saved. \(error).")
                        for i in 0..<index {
                            self.scannedItems.removeAtIndex(i)
                        }
                        self.tableView.reloadData()
//                        self.updateLeftBarButtonItem()
                    }
                })
            }))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedItems.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = scannedItems[indexPath.row].barcode
        cell.textLabel?.textColor = .whiteColor()
        cell.detailTextLabel?.text = scannedItems[indexPath.row].name
        cell.detailTextLabel?.enabled = true
        cell.detailTextLabel?.textColor = .whiteColor()
        cell.backgroundColor = .blackColor()
        return cell
    }
    

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            scannedItems.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if scannedItems.count == 0 {
                self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        performSegueWithIdentifier("showDetails", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails" {
            let destinationVC = segue.destinationViewController as! DetailsOfItemViewController
            destinationVC.scannedItem = scannedItems[selectedRow]
        }
    }

}
