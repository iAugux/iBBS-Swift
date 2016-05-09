//
//  IBBSRegisterViewController.swift
//  iBBS
//
//  Created by Augus on 9/23/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON


class IBBSRegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var avatarImageView: IBBSAvatarImageView! {
        didSet{
            avatarImageView.antiOffScreenRendering = false
            avatarImageView.backgroundColor = CUSTOM_THEME_COLOR.darkerColor(0.75)
            avatarImageView.image           = AVATAR_PLACEHOLDER_IMAGE
        }
    }
    
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
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    override func loadView() {
        super.loadView()
        
        usernameTextField.delegate      = self
        emailTextField.delegate         = self
        passwordTextField.delegate      = self
        passwordAgainTextField.delegate = self
        
        view.backgroundColor = UIColor(patternImage: BACKGROUNDER_IMAGE!)
        
        // blur view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.alpha = BLUR_VIEW_ALPHA_OF_BG_IMAGE + 0.2
        view.insertSubview(blurView, atIndex: 0)
        blurView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        usernameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
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
        
        APIClient.defaultClient.userRegister(email!, username: username!, passwd: encryptedPasswd, success: { (json) -> Void in

            let model = IBBSModel(json: json)
            
            if model.success {
                
                // register successfully!
                APIClient.defaultClient.userLogin(username!, passwd: encryptedPasswd, success: { (json) -> Void in

                    IBBSLoginKey.saveTokenJson(json.object)
                    
                    IBBSToast.make(REGISTER_SUCESSFULLY, interval: TIME_OF_TOAST_OF_REGISTER_SUCCESS)
                    
                    executeAfterDelay(1, completion: {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    
                    }, failure: { (error) -> Void in
                        DEBUGLog(error)
                        IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
                })
                
            } else {
                
                // failed
                let alertCtl = UIAlertController(title: REGISTER_FAILED, message: model.message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: nil)
                alertCtl.addAction(cancelAction)
                
                self.presentViewController(alertCtl, animated: true, completion: nil)

            }
            }, failure: { (error) -> Void in
                DEBUGLog(error)
                IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
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
    
    
    // MARK: - 
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // dismiss keyboard
        _ = view.subviews.map() {
            if $0 is UITextField {
                $0.resignFirstResponder()
            }
        }
    }
}
