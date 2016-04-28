//
//  IBBSUserViewController.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit

class IBBSUserViewController: UIViewController {
    
    var user: User!
    
    private var textField996IsEmpty = true
    private var textField997IsEmpty = true
    private var textField998IsEmpty = true
    private var textField999IsEmpty = true
    
    private var blurView: UIVisualEffectView!
    private var changePasswordAction: UIAlertAction!
    
    private let segueIdentifier = "GoToChatViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userImageView: IBBSAvatarImageView! {
        didSet {
            userImageView.layer.cornerRadius = userImageView.frame.width / 2
            userImageView.userInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.text = user?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(dismissViewController)
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(goToChatViewController)
        
        configureViewsIfSelf()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == segueIdentifier else { return }
        
        guard let vc = segue.destinationViewController as? IBBSChatViewController else { return }
        
        vc.receiver = user
    }
    
    @objc private func goToChatViewController() {
        performSegueWithIdentifier(segueIdentifier, sender: nil)
    }
    
    private func configureViewsIfSelf() {
        
        guard let id = user?.id  else { return }
        guard let uid = IBBSLoginKey().uid else { return }
        
        guard id == uid else { return }
        
        // change to setting action
        navigationItem.rightBarButtonItem?.image  = UIImage(named: "settings")
        navigationItem.rightBarButtonItem?.action = #selector(showActionSheet)
    }
    
    @objc private func showActionSheet() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let passwdAction = UIAlertAction(title: CHANGE_PASSWORD, style: .Default) { (_) in
            self.changePassword()
        }
        
        let avatarAction = UIAlertAction(title: CHANGE_AVATAR, style: .Default) { (_) in
            self.changeAvatar()
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
        
        alertController.addAction(passwdAction)
        alertController.addAction(avatarAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


// MARK: - change password

extension IBBSUserViewController {
    
    private func changePassword() {

        let key = IBBSLoginKey()
        
        var oldTF, newTF, confirmTF, usernameTF: UITextField!
        
        var username = key.username
        
        textField996IsEmpty = username == nil
        
        let msg = CHECK_DIGITS_OF_PASSWORD + "\n" + CHECK_DIGITS_OF_USERNAME
        
        let alertVC = UIAlertController(title: CHANGE_PASSWORD, message: msg, preferredStyle: .Alert)
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.tag = 996
            textField.addTarget(self, action: #selector(IBBSUserViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = HOLDER_USERNAME
            textField.text = username
            textField.enablesReturnKeyAutomatically = true
            usernameTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.tag = 997
            textField.addTarget(self, action: #selector(IBBSUserViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = OLD_PASSWORD
            textField.secureTextEntry = true
            textField.enablesReturnKeyAutomatically = true
            oldTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.tag = 998
            textField.addTarget(self, action: #selector(IBBSUserViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = NEW_PASSWORD
            textField.secureTextEntry = true
            textField.enablesReturnKeyAutomatically = true
            newTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) in
            textField.tag = 999
            textField.addTarget(self, action: #selector(IBBSUserViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = CONFIRM_PASSWORD
            textField.secureTextEntry = true
            textField.enablesReturnKeyAutomatically = true
            confirmTF = textField
        }
        
        self.changePasswordAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (action: UIAlertAction) -> Void in
            
            self.removeBlurView()
            self.setAllTextFieldToEmptyStatus()
            
            guard let old = oldTF.text, let new = newTF.text, let confirm = confirmTF.text else { return }
            
            guard !(old.isEmpty || new.isEmpty || confirm.isEmpty) else { return }
            
            guard new == confirm else {
                IBBSToast.make(PASSWD_MUST_BE_THE_SAME, delay: 0, interval: 3)
                return
            }
            
            guard old != new else {
                IBBSToast.make(PLEASE_SET_NEW_PASSWORD, delay: 0, interval: 3)
                return
            }
            
            let oldMD5 = old.MD5()
            let newMD5 = new.MD5()
            
            // ready to change password
            
            username = usernameTF.text
            
            APIClient.defaultClient.changePassword(username, oldPassword: oldMD5, newPassword: newMD5, success: { (json) in
                
                let model = IBBSModel(json: json)
                
                print(json)
                
                if model.success {
                    self.alertToLogin(username, password: newMD5, title: model.message, message: LOGIN_NOW)
                } else {
                    IBBSToast.make(model.message, delay: 0, interval: 3)
                }
                
                }, failure: { (error) in
                    DEBUGLog(error)
                    IBBSToast.make(ERROR_MESSAGE, delay: 0, interval: 3)
            })
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel) { (_) -> Void in
            
            self.removeBlurView()
            
            alertVC.dismissViewControllerAnimated(true , completion: {
                self.setAllTextFieldToEmptyStatus()
            })
        }
        
        self.changePasswordAction.enabled = false
        
        alertVC.addAction(self.changePasswordAction)
        alertVC.addAction(cancelAction)
        
        self.addBlurView()

        UIApplication.topMostViewController?.presentViewController(alertVC, animated: true, completion: {
            
            guard let textFields = alertVC.textFields where textFields.count > 1 else { return }
            
            let index = username == nil ? 0 : 1
            textFields[index].becomeFirstResponder()
        })
    }
    
    private func alertToLogin(username: AnyObject, password: AnyObject, title: String?, message: String?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (_) in
            self.login(username, password: password)
            
            self.removeBlurView()
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: { _ in
            self.removeBlurView()
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        addBlurView()
        
        UIApplication.topMostViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func login(username: AnyObject, password: AnyObject) {
        
        APIClient.defaultClient.userLogin(username, passwd: password, success: { (json) -> Void in
            
            let model = IBBSModel(json: json)
            
            // something wrong , alert!!
            if !model.success {
                IBBSToast.make(model.message, delay: 0, interval: 2)
            } else {
                IBBSToast.make(model.message, delay: 0, interval: 1.5)
                
                // success , keep token and other info
                IBBSLoginKey.saveTokenJson(json.object)
            }
            
        }) { (error ) -> Void in
            DEBUGLog(error)
            IBBSToast.make(ERROR_MESSAGE, delay: 0, interval: 2)
        }
    }
   
    private func setAllTextFieldToEmptyStatus() {
        textField996IsEmpty = true
        textField997IsEmpty = true
        textField998IsEmpty = true
        textField999IsEmpty = true
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        
        let isEmpty = textField.text?.isEmpty ?? true
        
        let lengthValid = textField.text?.utf8.count > 5
        
        switch textField.tag {
        case 996: textField996IsEmpty = isEmpty || !(textField.text?.utf8.count > 4)
        case 997: textField997IsEmpty = isEmpty || !lengthValid
        case 998: textField998IsEmpty = isEmpty || !lengthValid
        case 999: textField999IsEmpty = isEmpty || !lengthValid
        default: return
        }
        
        let enabled = !textField996IsEmpty && !textField997IsEmpty && !textField998IsEmpty && !textField999IsEmpty
        
        changePasswordAction?.enabled = enabled
    }
    
    private func addBlurView() {
        
        guard let topView = UIApplication.topMostViewController?.view else { return }

        blurView?.removeFromSuperview()
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.alpha = 0
        topView.addSubview(blurView)
        blurView.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        })
        
        UIView.animateWithDuration(0.3) { 
            self.blurView?.alpha = 1
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(removeBlurView))
        blurView.addGestureRecognizer(recognizer)
    }
    
    @objc private func removeBlurView() {
        UIView.animateWithDuration(0.3, animations: {
            self.blurView?.alpha = 0
            }) { (_) in
                self.blurView?.removeFromSuperview()
                self.blurView = nil
        }
    }
    
}


// MARK: - Change Avatar

extension IBBSUserViewController {

    private func changeAvatar() {
        
    }
    
}
