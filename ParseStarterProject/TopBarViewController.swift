//
//  ViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-09-25.
//  Copyright © 2016 Sam Kheirandish. All rights reserved.
//

import UIKit

class TopBarViewController: UIViewController {
    
    let menuButton = UIButton()
    let listButton = ListButton()
    var height = CGFloat()
    let text = UILabel()
    var mode : String! = "View Mode" {
        didSet {
            text.text = mode
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parentVC = MainViewController()
        height = parentVC.topBarHeight
        let topMargin: CGFloat = 10.0
        
        self.view.backgroundColor = .blackColor()
        
        text.frame = CGRect(x: 0.0, y: topMargin, width: self.view.frame.width, height: height)
        text.text = self.mode
        text.adjustsFontSizeToFitWidth = true
        text.textColor = .whiteColor()
        text.textAlignment = .Center
        self.view.addSubview(text)
        
        
        let menuBImage = UIImage(named: "menu")
        menuButton.frame = CGRect(x: 20.0, y: (height/2 - menuBImage!.size.height/2) + topMargin, width: menuBImage!.size.width, height: menuBImage!.size.height)
        menuButton.setImage(menuBImage, forState: .Normal)
        menuButton.addTarget(self, action: #selector(menuButtonPressed), forControlEvents: .TouchUpInside)
        self.view.addSubview(menuButton)
        
        let listBImage = UIImage(named: "list")
        let frame = CGRect(x: (self.view.frame.width - listBImage!.size.width - 25.0), y: (height/2 - listBImage!.size.height/2) + topMargin, width: listBImage!.size.width, height: listBImage!.size.height)
        listButton.initialFrame = frame
        listButton.setImage(listBImage, forState: .Normal)
        listButton.addTarget(self, action: #selector(listButtonPressed), forControlEvents: .TouchUpInside)
        self.view.addSubview(listButton)
    }
    
    func menuButtonPressed() {
        spinMenuButton()
        if let containerVC = self.parentViewController as? MainViewController {
            containerVC.toggleSideMenu()
        }
    }
    
    func spinMenuButton() {
        let animationDuration = 0.4
        let fillmode = kCAFillModeBackwards
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = 2 * CGFloat(M_PI)
        rotateAnimation.duration = animationDuration
        rotateAnimation.fillMode = fillmode
        menuButton.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    func listButtonPressed() {
        if let parentVC = self.parentViewController as? MainViewController {
            parentVC.performSegueWithIdentifier("showList", sender: self)
        }
    }
    
    func updateTitle(title: String) {
        UIView.transitionWithView(self.text, duration: 0.5, options: .TransitionFlipFromBottom, animations: nil) { (_) in
            self.mode = title
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
