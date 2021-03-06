//
//  SettingsTableTableViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-25.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class SettingsTableTableViewController: UITableViewController {

    var index: Int = 0 {
        didSet {
            if let parentVC = self.parentViewController as? MainViewController {
                parentVC.deviceModeIndex = index
            }
        }
    }
    let modesArray : [String] = ["View mode", "Archive mode", "Defrost mode", "Discharge mode"]
    let parseBackendHandler = ParseBackendHandler()
    var isFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 4
        default:
            return 1
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.accessoryType = .None
            cell.textLabel!.text = modesArray[indexPath.row]
            cell.textLabel?.textColor = .whiteColor()
            cell.textLabel?.textAlignment = .Justified
            cell.backgroundColor = .clearColor()
            cell.selectionStyle = .None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.textLabel?.text = "About"
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.textColor = .whiteColor()
            cell.textLabel?.textAlignment = .Justified
            cell.backgroundColor = .clearColor()
            cell.selectionStyle = .None
            cell.highlighted = false

            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = .redColor()
            cell.textLabel?.textAlignment = .Justified
            cell.backgroundColor = .clearColor()
            cell.selectionStyle = .None
            cell.highlighted = false
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.textColor = UIColor.darkGrayColor()
            index = indexPath.row
        case 1:
            if let parentVC = self.parentViewController as? MainViewController {
                parentVC.performSegueWithIdentifier("showAboutUs", sender: nil)
            }
        default:
            logOut()
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.textColor = UIColor.whiteColor()
        }
    }

    
//    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        return NSIndexPath(forRow: index, inSection: 0)
//    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
    func logOut() {
        let alertC = UIAlertController(title: "Are you sure you want to logout?", message: nil, preferredStyle: .ActionSheet)
        alertC.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
            self.parseBackendHandler.logout({ (success, error) in
                if success {
                    let Login = self.storyboard!.instantiateViewControllerWithIdentifier("LoginPage")
                    self.presentViewController(Login, animated: true, completion: nil)
                } else {
                    print(error)
                }
            })
        }))
        alertC.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        presentViewController(alertC, animated: true, completion: nil)
    }

}
