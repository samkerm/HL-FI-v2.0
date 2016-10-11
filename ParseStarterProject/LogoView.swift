//
//  AnimatedMaskLabel.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-10-06.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable class LogoView: UIView {
    
    let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        
        // Configure the gradient here
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let colors = [
            UIColor.lightGrayColor().CGColor,
            UIColor.whiteColor().CGColor,
            UIColor.lightGrayColor().CGColor
        ]
        gradientLayer.colors = colors
        
        let locations = [
            0.25,
            0.5,
            0.75
        ]
        gradientLayer.locations = locations
        
        return gradientLayer
    }()
    
    let textAttributes : [String: AnyObject] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .Center
        
        return [
            NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 30.0)!,
            NSParagraphStyleAttributeName:style
        ]
    }()
    
    @IBInspectable var text: String! {
        didSet {
            setNeedsDisplay()
            
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
            text.drawInRect(bounds, withAttributes: textAttributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.clearColor().CGColor
            maskLayer.frame = CGRectOffset(bounds, bounds.size.width, 0)
            maskLayer.contents = image!.CGImage
            
            gradientLayer.mask = maskLayer
        }
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = CGRect(
            x: -bounds.size.width,
            y: bounds.origin.y,
            width: 3 * bounds.size.width,
            height: bounds.size.height)
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        layer.addSublayer(gradientLayer)
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.75, 1.0, 1.0]
        gradientAnimation.duration = 3.0
        gradientAnimation.repeatCount = Float.infinity
        
        gradientLayer.addAnimation(gradientAnimation, forKey: nil)
    }
    
}
