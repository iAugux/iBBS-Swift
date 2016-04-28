//
//  IBBSContext.swift
//  iBBS
//
//  Created by Augus on 9/15/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class IBBSContext {
    
    private static let kNodesId = "kNodes"
    private static let kLoginFeedbackJson = "kLoginFeedbackJson"
    
    
    // MARK: - Login
    
    static func loginIfNeeded(alertMessage message: String?, completion: CompletionHandler?) {
        
        let key = IBBSLoginKey()
        
        guard !key.isValid else {
            completion?()
            return
        }
                
        let msg = message ?? PLEASE_LOGIN
        
        let loginAlertController = UIAlertController(title: "", message: msg, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default, handler: { (_) -> Void in
            
            let vc = IBBSEffectViewController()
            vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            UIApplication.topMostViewController?.presentViewController(vc, animated: true, completion: nil)
            
            IBBSContext.login(cancelled: {
                vc.dismissViewControllerAnimated(true , completion: nil)
                
                }, completion: {
                    
                    vc.dismissViewControllerAnimated(true, completion: nil)
                    completion?()
            })
        })
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel , handler: nil)
        loginAlertController.addAction(cancelAction)
        loginAlertController.addAction(okAction)
        
        UIApplication.topMostViewController?.presentViewController(loginAlertController, animated: true, completion: nil)
    }
    
    static func login(cancelled cancelled: CompletionHandler? = nil, completion: CompletionHandler?) {
        
        var username, password: UITextField!
      
        let alertVC = UIAlertController(title: BUTTON_LOGIN, message: INSERT_UID_AND_PASSWD, preferredStyle: .Alert)
        
        alertVC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = HOLDER_USERNAME
            username = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = HOLDER_PASSWORD
            textField.secureTextEntry = true
            textField.enablesReturnKeyAutomatically = true
            password = textField
        }
        
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (action: UIAlertAction) -> Void in
            
            let encryptedPasswd = password.text?.MD5()
            
            APIClient.defaultClient.userLogin(username.text!, passwd: encryptedPasswd!, success: { (json) -> Void in
                
                let model = IBBSLoginModel(json: json)
                
                // something wrong , alert!!
                if !model.success {
                    let alert = UIAlertController(title: ERROR_MESSAGE, message: model.message, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: { (_) -> Void in
                        self.login(cancelled: nil, completion: nil)
                        alertVC.dismissViewControllerAnimated(true , completion: nil)
                    })
                    
                    alert.addAction(cancelAction)
                    UIApplication.topMostViewController?.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    // success , keep token and other info
                    IBBSLoginKey.saveTokenJson(json.object)

                    completion?()
                }
                
                
                }) { (error ) -> Void in
                    DEBUGLog(error)
            }
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel) { (_) -> Void in
            alertVC.dismissViewControllerAnimated(true , completion: nil)
            cancelled?()
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        UIApplication.topMostViewController?.presentViewController(alertVC, animated: true, completion: nil)
    }

    
    // MARK: - Logout
    
    static func logout(completion completion: CompletionHandler?) {
        
        let alertController = UIAlertController(title: "", message: SURE_TO_LOGOUT, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Default, handler: nil)
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (_) -> Void in
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey(self.kLoginFeedbackJson)
            
            completion?()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        UIApplication.topMostViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Nodes
    
    static func saveNodes(nodes: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(kNodesId)
        userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(nodes), forKey: kNodesId)
        userDefaults.synchronize()
    }
    
    static func getNodes() -> JSON? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data: AnyObject? = userDefaults.objectForKey(kNodesId)
        if let obj: AnyObject = data {
            let json: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(obj as! NSData)
            return JSON(json!)
        }
        return nil
    }
    
    
    // MARK: - Avatar
    
    static func configureCurrentUserAvatar(imageView: UIImageView) {
        
        let json = IBBSLoginKey()
        
        guard let avatar = json.avatar else {
            imageView.image = AVATAR_PLACEHOLDER_IMAGE
            return
        }
        
        imageView.kf_setImageWithURL(avatar, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
    }
    
}

