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
