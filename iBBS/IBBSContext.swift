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
    static let sharedInstance = IBBSContext()
    
    private let nodesId = "nodes"
    let loginFeedbackJson = "loginFeedbackJson"

    
    func isLogin(completionHandler: ((isLogin: Bool) -> Void)) {
        
        if let json = IBBSContext.sharedInstance.getLoginData() {
            let uid = json["uid"].stringValue
            let token = json["token"].stringValue
            APIClient.sharedInstance.isLogin(uid, token: token, success: { (json) -> Void in
                print(json)
                if json["code"].intValue == 1 {
                    completionHandler(isLogin: true)
                    
                }else{
                    let msg = json["msg"].stringValue
                   UIApplication.topMostViewController()?.view.makeToast(message: msg, duration: 4, position: HRToastPositionTop)
                    completionHandler(isLogin: false)
                    
                }
                }, failure: { (error) -> Void in
                    print(error)
                    completionHandler(isLogin: false)
            })
        }else{
            completionHandler(isLogin: false)
        }
    }
    
//    /**
//    if you don't want to get a alert view of login when it didn't login , you should leave the target nil.
//    
//    - parameter vc: presenting view controller
//    
//    - returns: Bool
//    */
//    func isLogin(target vc: UIViewController?) -> Bool {
//        var isLogin = false
//        if let data = IBBSContext.sharedInstance.getLoginData() {
//            let token = data["token"].stringValue
//            let uid = data["uid"].stringValue
//            APIClient.sharedInstance.getMessages(uid, token: token, success: { (json) -> Void in
//                print(json)
//                if json["code"].intValue == 1{
//                    isLogin = true
//                }
//                else {
//                    // failed to verify, login again
//                    if vc != nil {
//                        let msg = json["msg"].stringValue
//                        vc?.view.makeToast(message: msg, duration: 6, position: HRToastPositionTop)
//                        // logout first
//                        let userDefaults = NSUserDefaults.standardUserDefaults()
//                        userDefaults.removeObjectForKey(self.loginFeedbackJson)
//                        // then login
//                        self.login(target: vc!, completion: {
//                            isLogin = true
//                            
//                        })
//                    }
//                }
//                }, failure: { (error) -> Void in
//                    print(error)
//            })
//        }
//        return isLogin
//    }

    
    func login(cancelled cancelled: (() -> Void)?, completion: (() -> Void)?) {
        var username, password: UITextField!
        
        let alertVC = UIAlertController(title: BUTTON_LOGIN, message: INSERT_UID_AND_PASSWD, preferredStyle: .Alert)
        
        alertVC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = HOLDER_USERNAME
            username = textField
        }
        alertVC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = HOLDER_PASSWORD
            textField.secureTextEntry = true
            password = textField
        }
        
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (action: UIAlertAction) -> Void in
            APIClient.sharedInstance.userLogin(username.text!, passwd: password.text!, success: { (json) -> Void in
                print(json)
                // something wrong , alert!!
                if json["code"].intValue == 0 {
                    let msg = json["msg"].stringValue
                    let alert = UIAlertController(title: ERROR_MESSAGE, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: { (_) -> Void in
                        self.login(cancelled: nil, completion: nil)
                        alertVC.dismissViewControllerAnimated(true , completion: nil)
                    })
                    alert.addAction(cancelAction)
                    UIApplication.topMostViewController()?.presentViewController(alert, animated: true, completion: nil)
                }else{
                    // success , keep token and other info
                    IBBSContext.sharedInstance.saveLoginData(json.object)
                    if let completionHandler = completion {
                        completionHandler()
                    }
                }
                
                
                }) { (error ) -> Void in
                    print(error)
            }
        }
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel) { (_) -> Void in
            alertVC.dismissViewControllerAnimated(true , completion: nil)
            if let cancelHandler = cancelled {
                cancelHandler()
            }
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        UIApplication.topMostViewController()?.presentViewController(alertVC, animated: true, completion: nil)
        
        
    }
    
    func logout(completion completion: (() -> Void)?){
        
        let alertController = UIAlertController(title: "", message: SURE_TO_LOGOUT, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (_) -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey(self.loginFeedbackJson)
            
            if let completionHandler = completion {
                completionHandler()
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        UIApplication.topMostViewController()?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func saveLoginData(data: AnyObject) {
        print("----\(data)-----")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(data), forKey: loginFeedbackJson)
        userDefaults.synchronize()
    }
    
    func getLoginData() -> JSON? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let data = userDefaults.objectForKey(loginFeedbackJson) {
            let json = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData)
            return JSON(json!)
        }
        
        return nil
    }
    
    func saveNodes(nodes:AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(nodes), forKey: nodesId)
        userDefaults.synchronize()
    }
    
    func getNodes() -> JSON? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data: AnyObject? = userDefaults.objectForKey(nodesId)
        if let obj: AnyObject = data {
            let json: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(obj as! NSData)
            return JSON(json!)
        }
        return nil
    }
    
    func configureCurrentUserAvatar(imageView: UIImageView){
        let data = IBBSContext.sharedInstance.getLoginData()
        if let json = data {
            let avatar = json["avatar"].stringValue
            if avatar.utf16.count == 0 {
                print("there is no avatar, set a image holder")
                imageView.image = UIImage(named: "avatar_placeholder")
            }else{
                if let url = NSURL(string: avatar as String) {
                    imageView.kf_setImageWithURL(url, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
                }
            }
        }
    }
    
    
}

