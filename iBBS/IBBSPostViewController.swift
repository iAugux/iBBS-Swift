//
//  IBBSPostViewController.swift
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


class IBBSPostViewController: IBBSEditorBaseViewController {

    private let nodeID = "board"
    private let articleTitle = "title"
    private let content = "content"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.translucent = false
//        focusTextEditor()
//        
//        let delayInSeconds: Double = 0.4
//        let popTime = dispatch_time(DISPATCH_TIME_NOW,Int64(Double(NSEC_PER_SEC) * delayInSeconds))
//        dispatch_after(popTime, dispatch_get_main_queue(), {
//            toolbarHolder?.hidden = false
//            
//        })
        
        
        // TODO: - There is a bug in `ZSSRichTextEditor`. If you show keyboard immediately, then the color picker won't work correctly.
        
//        let delayInSeconds: Double = 1
//        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delayInSeconds))
        let weakSelf = self
        dispatch_async(dispatch_get_main_queue(), {
            weakSelf.focusTextEditor()
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 1.2)), dispatch_get_main_queue()) { () -> Void in
            self.toolbarHolder.hidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.translucent = true

        toolbarHolder?.hidden = true
        blurTextEditor()
    }

    override func sendAction() {
        super.sendAction()
        
        blurTextEditor()
        if getHTML().ausTrimHtmlInWhitespaceAndNewlineCharacterSet().isEmpty {
            configureAlertController()
            return
        }
        shouldShowKeyboard = false
        let userID: String, token: String
        contentsArrayOfPostArticle.setValue(getHTML(), forKey: content)
        if let loginData = IBBSContext.sharedInstance.getLoginData() {
            userID = loginData["uid"].stringValue
            token = loginData["token"].stringValue
            DEBUGLog(userID)
            DEBUGLog(token)
            APIClient.sharedInstance.post(userID, nodeID: contentsArrayOfPostArticle[nodeID]!, content: contentsArrayOfPostArticle[content]!, title: contentsArrayOfPostArticle[articleTitle]!, token: token, success: { (json) -> Void in
                debugPrint(json)

                let msg = json["msg"].stringValue
                if json["code"].intValue == 1 { //post successfully
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kShouldReloadDataAfterPosting, object: nil)
                    
                    ASStatusBarToast.makeStatusBarToast(msg, interval: TIME_OF_TOAST_OF_POST_SUCCESS)

                    let delayInSeconds: Double = 0.3
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true , completion: nil)
                    })

                } else {
                    ASStatusBarToast.makeStatusBarToast(msg, interval: TIME_OF_TOAST_OF_POST_FAILED)

                    let delayInSeconds: Double = 1.5
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    })

                }
                
                }) { (error ) -> Void in
                    DEBUGLog(error)
                    ASStatusBarToast.makeStatusBarToast(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
            }
            DEBUGLog(contentsArrayOfPostArticle)
        }
    }
    
    func cancelAction(){
        blurTextEditor()
        dismissViewControllerAnimated(true , completion: nil)
        
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
