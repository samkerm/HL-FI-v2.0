//
//  ListButton.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-10-05.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ListButton: UIButton {
    
    var initialFrame : CGRect! {
        didSet{
            self.frame = initialFrame
            self.frame.size = CGSizeMake(0.0, 0.0)
        }
    }
    
    var popToExistance : Bool! {
        didSet{
            if (popToExistance != nil) {
                if popToExistance == true {
                    UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7, options: .CurveEaseOut, animations: {
                        self.frame.size = self.initialFrame.size
                        }, completion: nil)
                } else {
                    UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: .CurveEaseOut, animations: {
                        self.frame.size = CGSizeMake(0.0, 0.0)
                        }, completion: nil)
                }
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
