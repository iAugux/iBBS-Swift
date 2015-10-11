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
        self.navigationController?.navigationBar.translucent = false
//        self.focusTextEditor()
//        
//        let delayInSeconds: Double = 0.4
//        let popTime = dispatch_time(DISPATCH_TIME_NOW,Int64(Double(NSEC_PER_SEC) * delayInSeconds))
//        dispatch_after(popTime, dispatch_get_main_queue(), {
//            self.toolbarHolder?.hidden = false
//            
//        })
        
        
        // TODO: - There is a bug in `ZSSRichTextEditor`. If you show keyboard immediately, then the color picker won't work correctly.
        
        let delayInSeconds: Double = 1
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delayInSeconds))
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.focusTextEditor()
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 1.2)), dispatch_get_main_queue()) { () -> Void in
            self.toolbarHolder.hidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true

        self.toolbarHolder?.hidden = true
        self.blurTextEditor()
    }

    func sendAction() {
        self.blurTextEditor()
        if getHTML().ausTrimHtmlInWhitespaceAndNewlineCharacterSet().isEmpty {
            self.configureAlertController()
            return
        }
        self.shouldShowKeyboard = false
        let userID: String, token: String
        contentsArrayOfPostArticle.setValue(getHTML(), forKey: content)
        if let loginData = IBBSContext.sharedInstance.getLoginData() {
            userID = loginData["uid"].stringValue
            token = loginData["token"].stringValue
            print(userID)
            print(token)
            APIClient.sharedInstance.post(userID, nodeID: contentsArrayOfPostArticle[nodeID]!, content: contentsArrayOfPostArticle[content]!, title: contentsArrayOfPostArticle[articleTitle]!, token: token, success: { (json) -> Void in
                print(json)

                let msg = json["msg"].stringValue
                if json["code"].intValue == 1 { //post successfully
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kShouldReloadDataAfterPosting, object: nil)
                    
                    self.view?.makeToast(message: msg, duration: TIME_OF_TOAST_OF_POST_SUCCESS, position: HRToastPositionTop)
                    let delayInSeconds: Double = 0.3
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true , completion: nil)
                    })

                }else{
                    self.view?.makeToast(message: msg, duration: TIME_OF_TOAST_OF_POST_FAILED, position: HRToastPositionTop)
                    let delayInSeconds: Double = 1.5
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    })

                }
                
                }) { (error ) -> Void in
                    print(error)
                    self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
            }
            print(contentsArrayOfPostArticle)
        }
    }
    
    func cancelAction(){
        self.blurTextEditor()
        self.dismissViewControllerAnimated(true , completion: nil)
        
    }

    func configureAlertController() {
        let alertController = UIAlertController(title: "", message: YOU_HAVENOT_WROTE_ANYTHING, preferredStyle: .Alert)
        let action = UIAlertAction(title: GOT_IT, style: .Cancel) { (_) -> Void in
            self.focusTextEditor()
        }
        
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
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
