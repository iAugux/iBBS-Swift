//
//  SlidePanelViewController.swift
//  SlideMenu
//
//  Created by Augus on 4/27/15.
//  Copyright (c) 2015 Augus. All rights reserved.
//

import UIKit
import SwiftyJSON

class SlidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    struct MainStoryBoard {
        struct TableViewCellIdentifiers {
            static let slidePanelCell = "slidePanelCell"
        }
    }
    @IBOutlet weak var userProfileImage: UIImageView!{
        didSet{
            userProfileImage.layer.cornerRadius = 35.0
            userProfileImage.clipsToBounds = true
            self.configureLoginAndLogoutView(userProfileImage)
            self.fetchAvatarImage()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var loginAlertController: UIAlertController!
    internal var loginUserInfo: JSON!
    
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.grayColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchAvatarImage()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureLoginAndLogoutView(sender: UIImageView){
        let longTapGesture = UILongPressGestureRecognizer(target: self , action: "loginOrLogout:")
        sender.addGestureRecognizer(longTapGesture)
        sender.userInteractionEnabled = true
    }
    
    func loginOrLogout(gesture: UIGestureRecognizer){
        if gesture.state == .Began {
            let isLogin = false
            if isLogin {
                // do logout
            }else{
                // do login
                
                self.configureLoginAlertController()
            }
        }
        
    }
    
    func fetchAvatarImage(){
        if loginUserInfo != nil {
            let avatarUrl = NSURL(string: loginUserInfo["avatar"].stringValue)!
            if (self.userProfileImage.image != nil) {
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let dirPath = paths.stringByAppendingString("/images")
                let imagePath = paths.stringByAppendingString("/images/currentUserAvatar.png")
                let checkImage = NSFileManager.defaultManager()
                
                if (checkImage.fileExistsAtPath(imagePath)) {
                    let getImage = UIImage(contentsOfFile: imagePath)
                    self.userProfileImage?.image = getImage
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        do {
                            try checkImage.createDirectoryAtPath(dirPath, withIntermediateDirectories: true, attributes: nil)
                        }catch{}
                        
                        let getImage =  UIImage(data: NSData(contentsOfURL: avatarUrl)!)
                        UIImageJPEGRepresentation(getImage!, 100)!.writeToFile(imagePath, atomically: true)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.userProfileImage?.image = getImage
                            return
                        }
                    }
                }
                
            }
        }
        
    }
    
    func configureLoginAlertController(){
        var username, password: UITextField!
        loginAlertController = UIAlertController(title: "login", message: "Please input your username and password.", preferredStyle: .Alert)
        loginAlertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "username"
            username = textField
        }
        loginAlertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "password"
            textField.secureTextEntry = true
            password = textField
        }
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction) -> Void in
            APIClient.sharedInstance.userLogin(username.text!, passwd: password.text!, success: { (json) -> Void in
                print(json)
                self.saveLoginData(json)
                // something wrong , alert!!
                if Int(json["code"].stringValue) == 0 {
                    let msg = json["msg"].stringValue
                    let alert = UIAlertController(title: "Error Message", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: "Try again", style: .Cancel, handler: { (_) -> Void in
                        self.configureLoginAlertController()
                    })
                    alert.addAction(cancelAction)
                    self.presentViewController(alert , animated: true, completion: nil)
                }else{
                    // success , keep token and other info
                    self.loginUserInfo = json
                    let avatarUrl = NSURL(string: json["avatar"].stringValue)
//                    let username = json["username"].stringValue
                    self.userProfileImage.sd_setImageWithURL(avatarUrl)
//                    NSUserDefaults.standardUserDefaults().setURL(avatarUrl, forKey: "userProfileImage")
//                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    
                    
                }
                
                
                }) { (error ) -> Void in
                    print(error)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) -> Void in
            self.loginAlertController.dismissViewControllerAnimated(true , completion: nil)
        }
        loginAlertController.addAction(okAction)
        loginAlertController.addAction(cancelAction)
        
        self.presentViewController(loginAlertController, animated: true, completion: nil)
    }
    
    func saveLoginData(json: JSON){
//        let docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//        let filePath = docPath.stringByAppendingString("/loginData.plist")
//        let datasource = NSMutableArray()
//        datasource.addObject(json["username"].stringValue)
//        datasource.addObject(json["avatar"].stringValue)
//        datasource.addObject(json["token"].stringValue)
//        datasource.writeToFile(filePath, atomically: true)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(json.arrayObject, forKey: "currentUserLoginData")
        userDefaults.setObject(json["username"].stringValue, forKey: "currentUserName")
        userDefaults.setObject(json["avatar"].stringValue, forKey: "currentUserAvatarUrl")
        userDefaults.setObject(json["token"].stringValue, forKey: "currentUserToken")
        userDefaults.synchronize()
    }
    
    
    
    // MARK: - table view delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(MainStoryBoard.TableViewCellIdentifiers.slidePanelCell)
        if cell == nil {
            cell = UITableViewCell()
            cell?.frame = CGRectZero
        }
        
        cell?.textLabel?.text = "@"
        cell?.backgroundColor = UIColor.clearColor()
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsetsZero
        cell?.separatorInset = UIEdgeInsetsZero
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("ok")
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
