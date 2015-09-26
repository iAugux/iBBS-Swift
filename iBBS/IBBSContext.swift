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
    
    
    func isLogin(presentingVC vc: UIViewController, completionHandler: ((isLogin: Bool) -> Void)) {
        
        if let json = IBBSContext.sharedInstance.getLoginData() {
            let uid = json["uid"].stringValue
            let token = json["token"].stringValue
            APIClient.sharedInstance.isLogin(uid, token: token, success: { (json) -> Void in
                print(json)
                if json["code"].intValue == 1 {
                    completionHandler(isLogin: true)
                    
                }else{
                    let msg = json["msg"].stringValue
                    vc.view.makeToast(message: msg, duration: 4, position: HRToastPositionTop)
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
//    if you don't want to get a alert view of login when it didn't login , you should leave the prentingVC nil.
//    
//    - parameter vc: presenting view controller
//    
//    - returns: Bool
//    */
//    func isLogin(presentingVC vc: UIViewController?) -> Bool {
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
//                        self.login(presentingVC: vc!, completion: {
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

    
    func login(presentingVC presentingVC: UIViewController, completion: (() -> Void)?) {
        var username, password: UITextField!
        let alertVC = UIAlertController(title: "login", message: "Please input your username and password.", preferredStyle: .Alert)
        
        alertVC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "username"
            username = textField
        }
        alertVC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "password"
            textField.secureTextEntry = true
            password = textField
        }
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction) -> Void in
            APIClient.sharedInstance.userLogin(username.text!, passwd: password.text!, success: { (json) -> Void in
                print(json)
                // something wrong , alert!!
                if json["code"].intValue == 0 {
                    let msg = json["msg"].stringValue
                    let alert = UIAlertController(title: "Error Message", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: "Try again", style: .Cancel, handler: { (_) -> Void in
                        self.login(presentingVC: presentingVC, completion: nil)
                        alertVC.dismissViewControllerAnimated(true , completion: nil)
                    })
                    alert.addAction(cancelAction)
                    presentingVC.presentViewController(alert , animated: true, completion: nil)
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) -> Void in
            alertVC.dismissViewControllerAnimated(true , completion: nil)
        }
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        presentingVC.presentViewController(alertVC, animated: true, completion: nil)
    }

    func logout(presentingVC presentingVC: UIViewController, completion: (() -> Void)?){
        
        let alertController = UIAlertController(title: "", message: "Are you sure to logout ?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (_) -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey(self.loginFeedbackJson)
            
            if let completionHandler = completion {
                completionHandler()
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentingVC.presentViewController(alertController, animated: true, completion: nil)
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
            let avatar = json["avatar"].stringValue as NSString
            if avatar.length == 0 {
                print("there is no avatar, set a image holder")
                imageView.image = UIImage(named: "avatar_holder")
            }else{
                if let url = NSURL(string: avatar as String) {
                    imageView.kf_setImageWithURL(url)
                }
            }
        }
    }
    
    
}

