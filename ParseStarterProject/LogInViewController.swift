//
//  LogInViewController.swift
//  HL-FI v2.0
//
//  Created by Sam Kheirandish on 2016-10-05.
//  Copyright © 2016 Parse. All rights reserved.
//


// It still needs to be modified to handle different devices dimensions
import UIKit
import AVFoundation

public func pause(seconds seconds: Double, completion:()->()) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    dispatch_after(time, dispatch_get_main_queue()) {
        completion()
    }
}

public func shake(object: AnyObject) {
    let shake = CABasicAnimation(keyPath: "position")
    shake.duration = 0.07
    shake.repeatCount = 4
    shake.autoreverses = true
    shake.fromValue = NSValue(CGPoint: CGPointMake(object.center.x - 10, object.center.y))
    shake.toValue = NSValue(CGPoint: CGPointMake(object.center.x + 10, object.center.y))
    object.layer.addAnimation(shake, forKey: "position")
    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
}

class LogInViewController: UIViewController {

    var loginState = true
    let highlightedColor = UIColor(red: 30/255, green: 34/255, blue: 36/255, alpha: 1.0)
    let unHighlightedColor = UIColor(red: 19/255, green: 22/255, blue: 23/255, alpha: 1.0)
    let parseBackendHandler = ParseBackendHandler()
    var curentUser = CurentUser()
    var loginButtonVerticalSpacing: CGFloat!
    var signupButtonVerticalSpacing: CGFloat!
    enum device {
        case iPhone6plus
        case iPhone6
        case iPhone5
        case iPhone4
    }
    var curentDevice: device!
    
    enum signUpError {
        case None
        case MissMatchedPassword
        case ShortPassword
        case WrongEmailFormat
    }
    var errorState : signUpError = .None {
        didSet{
            shake(signupButton)
            switch errorState {
            case .MissMatchedPassword:
                passwordLabel.textColor = .redColor()
                retypePasswordLabel.textColor = .redColor()
                passwordTextField.secureTextEntry = false
                retypePasswordTextField.secureTextEntry = false
                passwordTextField.textColor = .redColor()
                retypePasswordTextField.textColor = .redColor()
                passwordTextField.text = "Not matched"
                retypePasswordTextField.text = "No Match"
                pause(seconds: 3.0, completion: {
                    self.passwordLabel.textColor = .whiteColor()
                    self.retypePasswordLabel.textColor = .whiteColor()
                    self.passwordTextField.textColor = .whiteColor()
                    self.retypePasswordTextField.textColor = .whiteColor()
                    self.passwordTextField.secureTextEntry = true
                    self.retypePasswordTextField.secureTextEntry = true
                    self.passwordTextField.text = ""
                    self.retypePasswordTextField.text = ""
                })
            case .ShortPassword:
                passwordLabel.textColor = .redColor()
                retypePasswordLabel.textColor = .redColor()
                passwordTextField.textColor = .redColor()
                retypePasswordTextField.textColor = .redColor()
                passwordTextField.secureTextEntry = false
                passwordTextField.text = "8 character or more"
                pause(seconds: 2.0, completion: {
                    self.passwordLabel.textColor = .whiteColor()
                    self.retypePasswordLabel.textColor = .whiteColor()
                    self.passwordTextField.textColor = .whiteColor()
                    self.retypePasswordTextField.textColor = .whiteColor()
                    self.passwordTextField.secureTextEntry = true
                    self.passwordTextField.text = ""
                    self.retypePasswordTextField.text = ""
                })
            case .WrongEmailFormat:
                emailTextField.textColor = .redColor()
                emailLabel.textColor = .redColor()
                emailTextField.text = "user@mail.ca"
                pause(seconds: 2.0, completion: {
                    self.emailTextField.textColor = .whiteColor()
                    self.emailLabel.textColor = .whiteColor()
                })
            default:
                break
            }
        }
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var retypePasswordLabel: UILabel!
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameUnderline: UIView!
    @IBOutlet weak var passwordUnderline: UIView!
    @IBOutlet weak var retypePasswordUnderline: UIView!
    @IBOutlet weak var firstnameUndeline: UIView!
    @IBOutlet weak var lastnameUnderline: UIView!
    @IBOutlet weak var emailUnderline: UIView!
    @IBOutlet weak var logo: LogoView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var signupVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameVerticalSpacingConstraint: NSLayoutConstraint!
    @IBAction func login(sender: AnyObject) {
        if loginState {
            if !usernameTextField.text!.isEmpty &&
                !passwordTextField.text!.isEmpty {
                parseBackendHandler.loginWithUsernameAndPassword(usernameTextField.text!,
                                                                 password: passwordTextField.text!,
                                                                 complition: { (success, error, curentUser) in
                    if success {
                        self.curentUser = curentUser
                        self.performSegueWithIdentifier("showMain", sender: self)
                    } else {
                        self.showAlert("Login Failed", message: error)
                    }
                })
            } else {
                shake(loginButton)
            }
        } else {
            view.bringSubviewToFront(loginButton)
            UIView.animateWithDuration(0.5, animations: {
                self.setLoginState()
            })
        }
    }
    @IBAction func signup(sender: AnyObject) {
        if loginState {
            view.bringSubviewToFront(signupButton)
            UIView.animateWithDuration(0.5, animations: {
                self.setSignupState()
            })
        } else {
            if !usernameTextField.text!.isEmpty &&
            !passwordTextField.text!.isEmpty &&
            !retypePasswordTextField.text!.isEmpty &&
            !firstnameTextField.text!.isEmpty &&
            !lastnameTextField.text!.isEmpty &&
            !emailTextField.text!.isEmpty {
                if passwordTextField.text != retypePasswordTextField.text {
                    self.errorState = .MissMatchedPassword
                } else if passwordTextField.text?.characters.count < 8 {
                    self.errorState = .ShortPassword
                } else if !isValidEmail(emailTextField.text!) {
                    self.errorState = .WrongEmailFormat
                } else {
                    self.parseBackendHandler.parseSignUpInBackgroundWithBlock(self.usernameTextField.text!,
                                                                              password: self.passwordTextField.text!,
                                                                              firstName: self.firstnameTextField.text!,
                                                                              lastName: self.lastnameTextField.text!,
                                                                              email: self.emailTextField.text!,
                                                                              completion: { (success, error, curentUser) in
                        if success {
                            self.curentUser = curentUser
                            self.performSegueWithIdentifier("showMain", sender: self)
                        } else {
                            self.showAlert("Problem Signing Up", message: error)
                        }
                    })
                }
            } else {
                shake(signupButton)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutContent()
        setLoginState()
        addSnowFlakes()
        
        logo.center.x = view.center.x
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        retypePasswordTextField.delegate = self
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func layoutContent() {
        switch view.frame.size.height {
        case 736:
            curentDevice = .iPhone6plus
            fallthrough
        case 667:
            curentDevice = .iPhone6
            logo.frame.origin.y = 40.0
            usernameVerticalSpacingConstraint.constant = 130
            loginButtonVerticalSpacing = 230.0
            signupButtonVerticalSpacing = 280.0
        case 568:
            curentDevice = .iPhone5
            logo.frame.origin.y = 40.0
            usernameVerticalSpacingConstraint.constant = 80
            loginButtonVerticalSpacing = 180.0
            signupButtonVerticalSpacing = 230.0
        default:
            curentDevice = .iPhone4
            logo.frame.origin.y = 20.0
            usernameVerticalSpacingConstraint.constant = 40
            loginButtonVerticalSpacing = 130.0
            signupButtonVerticalSpacing = 180.0
        }
    }
    
    func setLoginState() {
        view.bringSubviewToFront(loginButton)
        
        passwordTextField.returnKeyType = .Go
        retypePasswordTextField.alpha = 0.0
        retypePasswordLabel.alpha = 0.0
        retypePasswordUnderline.alpha = 0.0
        firstnameTextField.alpha = 0.0
        firstnameLabel.alpha = 0.0
        firstnameUndeline.alpha = 0.0
        lastnameTextField.alpha = 0.0
        lastnameLabel.alpha = 0.0
        lastnameUnderline.alpha = 0.0
        emailTextField.alpha = 0.0
        emailLabel.alpha = 0.0
        emailUnderline.alpha = 0.0
        
        self.loginVerticalSpacingConstraint.constant = loginButtonVerticalSpacing
        self.signupVerticalSpacingConstraint.constant = signupButtonVerticalSpacing
        self.loginButton.backgroundColor = self.highlightedColor
        self.signupButton.backgroundColor = self.unHighlightedColor
        
        self.loginState = true
        view.layoutIfNeeded()
    }
    
    func setSignupState() {
        view.bringSubviewToFront(signupButton)
        
        passwordTextField.returnKeyType = .Next
        retypePasswordTextField.alpha = 1.0
        retypePasswordLabel.alpha = 1.0
        retypePasswordUnderline.alpha = 1.0
        firstnameTextField.alpha = 1.0
        firstnameLabel.alpha = 1.0
        firstnameUndeline.alpha = 1.0
        lastnameTextField.alpha = 1.0
        lastnameLabel.alpha = 1.0
        lastnameUnderline.alpha = 1.0
        emailTextField.alpha = 1.0
        emailLabel.alpha = 1.0
        emailUnderline.alpha = 1.0
        
        self.loginVerticalSpacingConstraint.constant += 270.0
        self.signupVerticalSpacingConstraint.constant += 170.0
        self.signupButton.backgroundColor = self.highlightedColor
        self.loginButton.backgroundColor = self.unHighlightedColor
        
        self.loginState = false
        view.layoutIfNeeded()
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.ca"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func addSnowFlakes() {
        let rect = CGRect(x: 0.0, y: -70.0, width: view.bounds.width, height: 50.0)
        let emitter = CAEmitterLayer()
        emitter.frame = rect
        emitter.emitterShape = kCAEmitterLayerRectangle
        emitter.emitterPosition = CGPoint(x: rect.width/2, y: rect.height/2)
        emitter.emitterSize = rect.size
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "flake.png")!.CGImage
        emitterCell.birthRate = 150
        emitterCell.lifetime = 3.5
        emitter.emitterCells = [emitterCell]
        emitterCell.yAcceleration = 70.0
        emitterCell.xAcceleration = 10.0
        emitterCell.velocity = 20.0
        emitterCell.emissionLongitude = CGFloat(-M_PI)
        emitterCell.velocityRange = 200.0
        emitterCell.emissionRange = CGFloat(M_PI_2)
        emitterCell.color = UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 0.2).CGColor
        emitterCell.redRange   = 0.1
        emitterCell.greenRange = 0.1
        emitterCell.blueRange  = 0.1
        emitterCell.scale = 0.8
        emitterCell.scaleRange = 0.8
        emitterCell.scaleSpeed = -0.15
        emitterCell.alphaRange = 0.75
        emitterCell.alphaSpeed = -0.15
        emitterCell.lifetimeRange = 1.0
        view.layer.addSublayer(emitter)
    }
        
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Close", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! MainViewController
        destinationVC.curentUser = self.curentUser
    }

}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if loginState {
            if textField == usernameTextField {
                passwordTextField.becomeFirstResponder()
            } else if textField == passwordTextField {
                view.endEditing(true)
                self.login(loginButton)
            }
        } else {
            switch textField {
            case usernameTextField:
                passwordTextField.becomeFirstResponder()
            case passwordTextField:
                retypePasswordTextField.becomeFirstResponder()
            case retypePasswordTextField:
                firstnameTextField.becomeFirstResponder()
            case firstnameTextField:
                lastnameTextField.becomeFirstResponder()
            case lastnameTextField:
                emailTextField.becomeFirstResponder()
            default:
                view.endEditing(true)
                self.signup(loginButton)
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if curentDevice == .iPhone4 || curentDevice == .iPhone5 {
            switch textField {
            case lastnameTextField:
                self.usernameLabel.alpha = 0.0
                self.usernameTextField.alpha = 0.0
                self.usernameUnderline.alpha = 0.0
                self.usernameVerticalSpacingConstraint.constant = (curentDevice == .iPhone4) ? -10.0 : 30.0
            case emailTextField:
                self.usernameLabel.alpha = 0.0
                self.usernameTextField.alpha = 0.0
                self.usernameUnderline.alpha = 0.0
                self.passwordLabel.alpha = 0.0
                self.passwordTextField.alpha = 0.0
                self.passwordUnderline.alpha = 0.0
                self.usernameVerticalSpacingConstraint.constant = (curentDevice == .iPhone4) ? -60.0 : -20.0
            default:
                break
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.usernameLabel.alpha = 1.0
        self.usernameTextField.alpha = 1.0
        self.usernameUnderline.alpha = 1.0
        self.passwordLabel.alpha = 1.0
        self.passwordTextField.alpha = 1.0
        self.passwordUnderline.alpha = 1.0
        if curentDevice == .iPhone4 {
            self.usernameVerticalSpacingConstraint.constant  = 40
        } else if curentDevice == .iPhone5 {
            self.usernameVerticalSpacingConstraint.constant  = 80
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }

}
