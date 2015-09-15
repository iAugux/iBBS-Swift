//
//  IBBSContext.swift
//  iBBS
//
//  Created by Augus on 9/15/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON



var articleArray: NSMutableDictionary!


class IBBSContext {
    static let sharedInstance = IBBSContext()
    
    private let nodesId = "nodes"
    private let loginFeedbackJson = "loginFeedbackJson"
    
    
    func isLogin() -> Bool {
        if let data = IBBSContext.sharedInstance.getLoginData() {
            let token = data["token"].stringValue as NSString
            if token.length == 0 {
                return false
            }
            return true
            
        }
        return false
    }
    
    func login(var alertVC: UIAlertController, presentingVC: UIViewController, avatar: UIImageView){
        var username, password: UITextField!
        
        alertVC = UIAlertController(title: "login", message: "Please input your username and password.", preferredStyle: .Alert)
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
                if Int(json["code"].stringValue) == 0 {
                    let msg = json["msg"].stringValue
                    let alert = UIAlertController(title: "Error Message", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: "Try again", style: .Cancel, handler: { (_) -> Void in
                        self.login(alertVC, presentingVC: presentingVC, avatar: avatar)
                    })
                    alert.addAction(cancelAction)
                    presentingVC.presentViewController(alert , animated: true, completion: nil)
                }else{
                    // success , keep token and other info
                    IBBSContext.sharedInstance.saveLoginData(json.object)
                    IBBSContext.sharedInstance.configureCurrentUserAvatar(avatar)
                    
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

    func logout(var alertController: UIAlertController, presentingVC: UIViewController){
        
        alertController = UIAlertController(title: "", message: "Are you sure to logout ?", preferredStyle: .Alert)
        presentingVC.addChildViewController(alertController)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (_) -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey(self.loginFeedbackJson)
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
        let data = userDefaults.objectForKey(loginFeedbackJson)
        if let obj = data {
            let json = NSKeyedUnarchiver.unarchiveObjectWithData(obj as! NSData)
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
            let url = NSURL(string: json["avatar"].stringValue)
            imageView.sd_setImageWithURL(url)
        }
    }
    
    
}

