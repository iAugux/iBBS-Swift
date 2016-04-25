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
        
        let key = IBBSLoginKey()
        
        guard key.isValid else { return }
        
        let nodeId  = contentsArrayOfPostArticle[nodeID] as! Int
        let title   = contentsArrayOfPostArticle[articleTitle] as! String
        let content = getHTML()!
        
        APIClient.sharedInstance.post(key.uid, nodeID: nodeId, content: content, title: title, token: key.token, success: { (json) -> Void in
            
            
            print(json["code"].intValue)
            print(json["msg"].stringValue)
            
            let model = IBBSModel(json: json)
            
            print(model)
            
//
//            if model.success { //post successfully
//                
//                NSNotificationCenter.defaultCenter().postNotificationName(kShouldReloadDataAfterPosting, object: nil)
//                
//                IBBSToast.make(model.message, interval: TIME_OF_TOAST_OF_POST_SUCCESS)
//                
//                executeAfterDelay(0.3, completion: {
//                    self.dismissViewControllerAnimated(true , completion: nil)
//                })
//                
//            } else {
//                IBBSToast.make(model.message, interval: TIME_OF_TOAST_OF_POST_FAILED)
//                
//                executeAfterDelay(1.5, completion: {
//                    self.navigationController?.popViewControllerAnimated(true)
//                })
//                
//            }
            
        }) { (error) -> Void in
            DEBUGLog(error)
            IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
        }
    }
    
    private func cancelAction() {
        blurTextEditor()
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    private func configureAlertController() {
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
