//
//  IBBSRegisterViewController.swift
//  iBBS
//
//  Created by Augus on 9/23/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON


class IBBSRegisterViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var avatarImageView: IBBSAvatarImageView! {
        didSet{
            avatarImageView.backgroundColor = CUSTOM_THEME_COLOR.darkerColor(0.75)
            avatarImageView.image           = AVATAR_PLACEHOLDER_IMAGE
        }
    }
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.secureTextEntry = true
        }
    }
    @IBOutlet var passwordAgainTextField: UITextField! {
        didSet{
            passwordAgainTextField.secureTextEntry = true
        }
    }
    
    private var blurView: UIView!    
    override func loadView() {
        super.loadView()
        usernameTextField.delegate      = self
        emailTextField.delegate         = self
        passwordTextField.delegate      = self
        passwordAgainTextField.delegate = self
        view.backgroundColor       = UIColor(patternImage: BACKGROUNDER_IMAGE!)
        blurView                        = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame                  = view.frame
        blurView.alpha                  = BLUR_VIEW_ALPHA_OF_BG_IMAGE + 0.2
        view.insertSubview(blurView, atIndex: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.frame = view.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        //        UIView.animateWithDuration(0.75, animations: { () -> Void in
        //            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        //            UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromLeft, forView: navigationController!.view, cache: false)
        //        })
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func signupButton(sender: AnyObject) {
        
        let username = usernameTextField.text as NSString?
        let email = emailTextField.text as NSString?
        let passwd = passwordTextField.text as NSString?
        let passwdAgain = passwordAgainTextField.text as NSString?
        
        if username?.length == 0 || email?.length == 0 || passwd?.length == 0 || passwdAgain?.length == 0 {
            // not all the form are filled in
            let alertCtl = UIAlertController(title: FILL_IN_ALL_THE_FORM, message: CHECK_IT_AGAIN, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: I_WILL_CHECK, style: .Cancel, handler: nil)
            alertCtl.addAction(cancelAction)
            
            presentViewController(alertCtl, animated: true, completion: nil)
            return
        }
        
        if username?.length > 15 || username?.length < 4 {
            let alertCtl = UIAlertController(title: "", message: CHECK_DIGITS_OF_USERNAME, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: nil)
            alertCtl.addAction(cancelAction)
            
            presentViewController(alertCtl, animated: true, completion: nil)
            return
        }
        
        if !email!.isValidEmail(){
            // invalid email address
            let alertCtl = UIAlertController(title: "", message: INVALID_EMAIL, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: nil)
            alertCtl.addAction(cancelAction)
            
            presentViewController(alertCtl, animated: true, completion: nil)
            return
        }
        
        if passwd?.length < 6 {
            let alertCtl = UIAlertController(title: "", message: CHECK_DIGITS_OF_PASSWORD, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: I_KNOW, style: .Cancel, handler: nil)
            alertCtl.addAction(cancelAction)
            
            presentViewController(alertCtl, animated: true, completion: nil)
            return
        }
        
        if !passwd!.isValidPassword() {
            let alertCtl = UIAlertController(title: "", message: INVALID_PASSWORD, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: nil)
            alertCtl.addAction(cancelAction)
            
            presentViewController(alertCtl, animated: true, completion: nil)
            return

        }
        
        if passwd != passwdAgain {
            let alertCtl = UIAlertController(title: PASSWD_MUST_BE_THE_SAME, message: TRY_AGAIN, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: nil)
            alertCtl.addAction(cancelAction)
            
            presentViewController(alertCtl, animated: true, completion: nil)
            return
        }
        
        // everything is fine, ready to go
        let encryptedPasswd = (passwd as! String).MD5()
        APIClient.sharedInstance.userRegister(email!, username: username!, passwd: encryptedPasswd, success: { (json) -> Void in
            DEBUGLog(json)
            if json["code"].intValue == 1 {
                // register successfully!
                APIClient.sharedInstance.userLogin(username!, passwd: encryptedPasswd, success: { (json) -> Void in
                    DEBUGLog(json)
                    IBBSContext.sharedInstance.saveLoginData(json.object)
                    
                    self.view.makeToast(message: REGISTER_SUCESSFULLY, duration: TIME_OF_TOAST_OF_REGISTER_SUCCESS, position: HRToastPositionTop)
                    
                    let delayInSeconds: Double = 1
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        // do something
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    })
                    
                    }, failure: { (error) -> Void in
                        DEBUGLog(error)
                        self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                        
                })
                
            } else {
                // failed
                let errorInfo = json["msg"].stringValue
                let alertCtl = UIAlertController(title: REGISTER_FAILED, message: errorInfo, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: nil)
                alertCtl.addAction(cancelAction)
                
                self.presentViewController(alertCtl, animated: true, completion: nil)

            }
            }, failure: { (error) -> Void in
                DEBUGLog(error)
                self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                
        })
        
    }
    
    // MARK: - text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            passwordAgainTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
//            performSelector("signupButton:")
        }
        return true
    }
    
}
