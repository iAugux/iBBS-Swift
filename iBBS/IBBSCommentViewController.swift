//
//  IBBSCommentViewController.swift
//  iBBS
//
//  Created by Augus on 9/16/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSCommentViewController: ZSSRichTextEditor {
    
    var post_id = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldShowKeyboard = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAction")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: BUTTON_SEND, style: .Plain, target: self, action: "sendAction")
        self.navigationController?.navigationBar.translucent = false
        
        
        self.formatHTML = false
        
        // Set the base URL if you would like to use relative links, such as to images.
        self.baseURL = NSURL(string: "http://iAugus.com")
        
        // Set the toolbar item color
        self.toolbarItemTintColor = UIColor.blackColor()
        
        // Set the toolbar selected color
        self.toolbarItemSelectedTintColor = CUSTOM_THEME_COLOR
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = CUSTOM_THEME_COLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]
        
    }
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.focusTextEditor()
    }
    
    func cancelAction(){
        self.blurTextEditor()
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    func sendAction(){
        self.blurTextEditor()
        
        if getHTML().ausTrimHtmlInWhitespaceAndNewlineCharacterSet().isEmpty {
            self.configureAlertController()
            return
        }
        
        let content = getHTML()

        if let loginData = IBBSContext.sharedInstance.getLoginData(){
            let userID = loginData["uid"].stringValue
            let token = loginData["token"].stringValue
            
            APIClient.sharedInstance.comment(userID , postID: post_id, content: content, token: token, success: { (json ) -> Void in
                print(json)
                let msg = json["msg"].stringValue
                if json["code"].intValue == 1 { //comment successfully
                    self.view?.makeToast(message: msg, duration: 3, position: HRToastPositionTop)
                    
                    let delayInSeconds: Double = 0.3
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true , completion: nil)
                    })
                    
                }else{
                    self.view?.makeToast(message: msg, duration: 3, position: HRToastPositionTop)
                    let delayInSeconds: Double = 0.5
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.focusTextEditor()
                        
                    })
                    
                }
                }) { (error ) -> Void in
                    print(error)
                    self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                    
            }
        }
        
    }
    
    func configureAlertController() {
        let alertController = UIAlertController(title: "", message: YOU_HAVENOT_WROTE_ANYTHING, preferredStyle: .Alert)
        let action = UIAlertAction(title: GOT_IT, style: .Cancel) { (_) -> Void in
               self.focusTextEditor()
        }
        alertController.addAction(action)
        alertController.view.tintColor = CUSTOM_THEME_COLOR
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func showInsertURLAlternatePicker(){
        self.dismissAlertView()
        let picker = IBBSPickerViewController()
//        picker.demoViewForCommenting = self
        let nav = UINavigationController()
        nav.navigationBar.translucent = false
        self.presentViewController(nav, animated: true, completion: nil)
        
    }
    
    override func showInsertImageAlternatePicker() {
        self.dismissAlertView()
        let picker = IBBSPickerViewController()
//        picker.demoViewForCommenting = self
        picker.isInsertImagePicker = true
        let nav = UINavigationController()
        nav.navigationBar.translucent = false
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func exportHTML() {
        NSLog("%@", self.getHTML())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
