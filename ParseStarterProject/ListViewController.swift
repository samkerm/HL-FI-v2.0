//
//  ListViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-26.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    var topBarHeight = CGFloat()
    let animationTime: NSTimeInterval = 1.0
    
    let topbarViewController = ListTopBarViewController()
    var listTableViewController = ListTableViewController()
    
    var scannedItems = [ScannedItem]()
    var curentUser = CurentUser()
    var deviceModeIndex : Int!
    var selectedRow = 0
    let parseHandler = ParseBackendHandler()

    
    var comingFromMainVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        
        let parentVC = MainViewController()
        topBarHeight = parentVC.topBarHeight
        
        topbarViewController.view.frame = CGRect(x: 0, y: -topBarHeight, width: self.view.frame.width, height: topBarHeight)
        listTableViewController = storyboard?.instantiateViewControllerWithIdentifier("listTableViewController") as! ListTableViewController
        listTableViewController.view.frame = CGRect(x: 0, y: self.view.frame.size.height * 3 / 2, width: self.view.frame.width, height: self.view.frame.height - topBarHeight)
        
        addChildViewController(topbarViewController)
        view.addSubview(topbarViewController.view)
        topbarViewController.didMoveToParentViewController(self)
        
        addChildViewController(listTableViewController)
        view.addSubview(listTableViewController.view)
        listTableViewController.didMoveToParentViewController(self)
    }
    override func viewDidDisappear(animated: Bool) {
        comingFromMainVC = false
    }
    
    override func viewWillAppear(animated: Bool) {
        if comingFromMainVC {
            let barAnimation = CABasicAnimation(keyPath: "position.y")
            barAnimation.fromValue = -topBarHeight/2
            barAnimation.toValue = topBarHeight/2
            barAnimation.duration = animationTime
            barAnimation.fillMode = kCAFillModeBackwards
            topbarViewController.view.layer.addAnimation(barAnimation, forKey: nil)
            topbarViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: topBarHeight)
            let listAnimation = CABasicAnimation(keyPath: "position.y")
            listAnimation.fromValue = self.view.frame.size.height * 3 / 2
            listAnimation.toValue = self.view.frame.size.height / 2 + topBarHeight / 2
            listAnimation.duration = animationTime
            listAnimation.fillMode = kCAFillModeBackwards
            listTableViewController.view.layer.addAnimation(listAnimation, forKey: nil)
            listTableViewController.view.frame = CGRect(x: 0, y: topBarHeight, width: self.view.frame.width, height: self.view.frame.height - topBarHeight)
            if let listTableVC = self.childViewControllers.last as? ListTableViewController {
                listTableVC.curentUser = curentUser
                listTableVC.scannedItems = scannedItems
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        modalPresentationStyle = .Custom
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}