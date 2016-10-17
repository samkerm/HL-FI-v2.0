//
//  DetailsOfItemsTableViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-25.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DetailsOfItemViewController: UIViewController {

    var topBarHeight = CGFloat()
    let animationTime: NSTimeInterval = 1.0
    
    let detailsTopBarViewController = DetailsTopBarViewController()
    var detailsOfItemTableViewController = DetailsOfItemTableViewController()
    
    var scannedItem = ScannedItem() {
        didSet{
            if let tableVC = self.childViewControllers.last as? DetailsOfItemTableViewController {
                tableVC.scannedItem = scannedItem
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .redColor()
        
        let parentVC = MainViewController()
        topBarHeight = parentVC.topBarHeight

        detailsTopBarViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: topBarHeight)
        detailsOfItemTableViewController = storyboard?.instantiateViewControllerWithIdentifier("detailsTableViewController") as! DetailsOfItemTableViewController
        detailsOfItemTableViewController.view.frame = CGRect(x: 0, y: topBarHeight, width: self.view.frame.size.width, height: self.view.frame.height - topBarHeight)
        detailsOfItemTableViewController.scannedItem = scannedItem
        
        addChildViewController(detailsTopBarViewController)
        view.addSubview(detailsTopBarViewController.view)
        detailsTopBarViewController.didMoveToParentViewController(self)
        
        addChildViewController(detailsOfItemTableViewController)
        view.addSubview(detailsOfItemTableViewController.view)
        detailsOfItemTableViewController.didMoveToParentViewController(self)
        
        let panGuesture = UIPanGestureRecognizer(target: self, action: #selector(dismissVC(_:)))
        view.addGestureRecognizer(panGuesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissVC(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(recognizer.view!.superview!)
        let completed = (translation.x / (view.frame.size.width/2)) > 1 ? true : false
        if completed {
            self.dismissViewControllerAnimated(true, completion: nil)
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
