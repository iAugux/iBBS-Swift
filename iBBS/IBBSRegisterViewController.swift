//
//  IBBSRegisterViewController.swift
//  iBBS
//
//  Created by Augus on 9/23/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON


class IBBSRegisterViewController: UIViewController {
    
    
    @IBOutlet var avatarImageView: UIImageView! {
        didSet{
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.cornerRadius = 30.0
            avatarImageView.layer.borderWidth = 0.3
            avatarImageView.layer.borderColor = UIColor.blackColor().CGColor
            avatarImageView.backgroundColor = UIColor(red:0.887, green:0.945, blue:0.331, alpha:0.854)
            avatarImageView.image = UIImage(named: "avatar_holder")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        //        UIView.animateWithDuration(0.75, animations: { () -> Void in
        //            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        //            UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromLeft, forView: self.navigationController!.view, cache: false)
        //        })
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func signupButton(sender: AnyObject) {
        
        let username = usernameTextField.text as NSString?
        let email = emailTextField.text as NSString?
        let passwd = passwordTextField.text as NSString?
        let passwdAgain = passwordAgainTextField.text as NSString?
        
        if username?.length == 0 || email?.length == 0 || passwd?.length == 0 || passwdAgain?.length == 0 {
            // not all the form are filled in
            let alertView = UIAlertView(title: FILL_IN_ALL_THE_FORM, message: CHECK_IT_AGAIN, delegate: nil, cancelButtonTitle: I_WILL_CHECK)
            alertView.show()
            return
        }
        
        if username?.length > 15 || username?.length < 4 {
            let alertView = UIAlertView(title: "", message: CHECK_DIGITS_OF_USERNAME, delegate: nil, cancelButtonTitle: TRY_AGAIN)
            alertView.show()
            return
        }
        
        if !email!.isValidEmail(){
            // invalid email address
            let alertView = UIAlertView(title: "", message: INVALID_EMAIL, delegate: nil, cancelButtonTitle: TRY_AGAIN)
            alertView.show()
            return
        }
        
        if passwd?.length < 6 {
            let alertView = UIAlertView(title: "", message: CHECK_DIGITS_OF_PASSWORD, delegate: nil, cancelButtonTitle: I_KNOW)
            alertView.show()
            return
        }
        
        if passwd != passwdAgain {
            let alertView = UIAlertView(title: PASSWD_MUST_BE_THE_SAME, message: TRY_AGAIN, delegate: nil, cancelButtonTitle: TRY_AGAIN)
            alertView.show()
            return
        }
        
        // everything is fine, ready to go
        APIClient.sharedInstance.userRegister(email!, username: username!, passwd: passwd!, success: { (json) -> Void in
            print(json)
            if json["code"].intValue == 1 {
                // register successfully!
                APIClient.sharedInstance.userLogin(username!, passwd: passwd!, success: { (json) -> Void in
                    print(json)
                    IBBSContext.sharedInstance.saveLoginData(json.object)
                    
                    self.view.makeToast(message: REGISTER_SUCESSFULLY, duration: 3, position: HRToastPositionTop)
                    
                    let delayInSeconds: Double = 1
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        // do something
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    })
                    
                    }, failure: { (error) -> Void in
                        print(error)
                        self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                        
                })
                
            }else{
                // failed
                let errorInfo = json["msg"].stringValue
                let alertView = UIAlertView(title: REGISTER_FAILED, message: errorInfo, delegate: nil, cancelButtonTitle: TRY_AGAIN)
                alertView.show()
            }
            }, failure: { (error) -> Void in
                print(error)
                self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                
        })
        
    }
    
}
