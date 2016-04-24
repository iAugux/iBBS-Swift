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
        
        focusTextEditor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
                    
                    IBBSToast.make(msg, interval: TIME_OF_TOAST_OF_POST_SUCCESS)

                    executeAfterDelay(0.3, completion: {
                        self.dismissViewControllerAnimated(true , completion: nil)
                    })

                } else {
                    IBBSToast.make(msg, interval: TIME_OF_TOAST_OF_POST_FAILED)

                    executeAfterDelay(1.5, completion: {
                        self.navigationController?.popViewControllerAnimated(true)
                    })

                }
                
                }) { (error ) -> Void in
                    DEBUGLog(error)
                    IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
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

}
