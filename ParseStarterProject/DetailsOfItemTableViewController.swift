//
//  DetailsOfItemTableViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-30.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DetailsOfItemTableViewController: UITableViewController {

    var contentArray: [AnyObject] = []
    var titleArray = [""]
    var scannedItem = ScannedItem() {
        didSet{
            if scannedItem.type == "Plate" {
                titleArray = ["Barcode","Type", "Name", "PlateType", "Plate Status", "Project", "Library Name", "Creator's Username", "Creator's First Name", "Creator's Last Name", "Date Created", "Last Defrosted By", "Date Last Defrosted", "NumberOf Thaws", "Detailed Information"]
                contentArray.append(scannedItem.barcode)
                contentArray.append(scannedItem.type)
                contentArray.append(scannedItem.name)
                contentArray.append(scannedItem.plateType)
                contentArray.append(scannedItem.plateStatus)
                contentArray.append(scannedItem.project)
                contentArray.append(scannedItem.library)
                contentArray.append(scannedItem.creatorUsername)
                contentArray.append(scannedItem.creatorFirstName)
                contentArray.append(scannedItem.creatorLastName)
                contentArray.append(scannedItem.dateCreated)
                contentArray.append(scannedItem.lastDefrostedBy)
                contentArray.append(scannedItem.dateLastDefrosted)
                contentArray.append(scannedItem.numberOfThaws)
                contentArray.append(scannedItem.detailedInformation)
            } else {
                titleArray = ["Barcode","Type", "Name", "Creator's Username", "Creator's First Name", "Creator's Last Name", "Date Created", "Expiry Date", "Last Defrosted By", "Date Last Defrosted", "NumberOf Thaws", "Detailed Information"]
                contentArray.append(scannedItem.barcode)
                contentArray.append(scannedItem.type)
                contentArray.append(scannedItem.name)
                contentArray.append(scannedItem.creatorUsername)
                contentArray.append(scannedItem.creatorFirstName)
                contentArray.append(scannedItem.creatorLastName)
                contentArray.append(scannedItem.dateCreated)
                contentArray.append(scannedItem.expiryDate)
                contentArray.append(scannedItem.lastDefrostedBy)
                contentArray.append(scannedItem.dateLastDefrosted)
                contentArray.append(scannedItem.numberOfThaws)
                contentArray.append(scannedItem.detailedInformation)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = .blackColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contentArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row == contentArray.count - 1 {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
            cell.detailTextLabel?.numberOfLines = 0
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.textLabel?.textColor = .whiteColor()
        cell.detailTextLabel?.text = String(contentArray[indexPath.row]) == "" ? "--" : String(contentArray[indexPath.row])
        cell.detailTextLabel?.enabled = true
        cell.detailTextLabel?.textColor = .whiteColor()
        cell.backgroundColor = .blackColor()
        return cell
    }
    
    override func viewDidDisappear(animated: Bool) {
        contentArray.removeAll()
    }

   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let subtitleWidth = tableView.frame.size.width - 60
        if indexPath.row == contentArray.count - 1 {
            let string = contentArray[indexPath.row] as! NSString
            let atributes = [NSFontAttributeName : UIFont.systemFontOfSize(12.0)]
            let widthSize = string.sizeWithAttributes(atributes).width
            let heightSize = string.sizeWithAttributes(atributes).height
            let rowScale = widthSize / subtitleWidth
            return rowScale * heightSize + 44
        } else {
            return 44
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
