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

class IBBSCommentViewController: IBBSEditorBaseViewController {
    
    var post_id = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(IBBSCommentViewController.cancelAction))
        navigationController?.navigationBar.translucent = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // TODO: - There is a bug in `ZSSRichTextEditor`. If you show keyboard immediately, then the color picker won't work correctly.
        
        let delayInSeconds: Double = 0.9
        let popTime = dispatch_time(DISPATCH_TIME_NOW,Int64(Double(NSEC_PER_SEC) * delayInSeconds))
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.focusTextEditor()
        })
    }
    
    func cancelAction(){
        if getHTML().ausTrimHtmlInWhitespaceAndNewlineCharacterSet().isEmpty {
            blurTextEditor()
            dismissViewControllerAnimated(true , completion: nil)
        } else {
            let alert = UIAlertController(title: "", message: ARE_YOU_SURE_TO_GIVE_UP, preferredStyle: .Alert)
            let continueAction = UIAlertAction(title: BUTTON_CONTINUE, style: .Default, handler: { _ in
                self.focusTextEditor()
            })
            let cancelAction = UIAlertAction(title: BUTTON_GIVE_UP, style: .Cancel, handler: { _ in
                self.blurTextEditor()
                self.dismissViewControllerAnimated(true , completion: nil)
            })
            
            alert.addAction(continueAction)
            alert.addAction(cancelAction)
            let delayInSeconds: Double = 0.5
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delayInSeconds))
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        
    }
    
    override func sendAction() {
        super.sendAction()
        
        blurTextEditor()
        
        if getHTML().ausTrimHtmlInWhitespaceAndNewlineCharacterSet().isEmpty {
            configureAlertController()
            return
        }
        
        let content = getHTML()

        if let loginData = IBBSContext.sharedInstance.getLoginData(){
            let userID = loginData["uid"].stringValue
            let token = loginData["token"].stringValue
            
            APIClient.sharedInstance.comment(userID , postID: post_id, content: content, token: token, success: { (json ) -> Void in
                debugPrint(json)
                let msg = json["msg"].stringValue
                if json["code"].intValue == 1 { //comment successfully
                    self.view?.makeToast(message: msg, duration: TIME_OF_TOAST_OF_COMMENT_SUCCESS, position: HRToastPositionTop)
                    
                    let delayInSeconds: Double = 0.3
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true , completion: nil)
                    })
                    
                } else {
                    self.view?.makeToast(message: msg, duration: TIME_OF_TOAST_OF_COMMENT_FAILED, position: HRToastPositionTop)
                    let delayInSeconds: Double = 0.5
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.focusTextEditor()
                        
                    })
                    
                }
                }) { (error ) -> Void in
                    DEBUGLog(error)
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
        presentViewController(alertController, animated: true, completion: nil)
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
