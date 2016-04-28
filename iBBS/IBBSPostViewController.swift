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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.translucent = false
        
        executeAfterDelay(0.3) {
            self.focusTextEditor()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        blurTextEditor()
    }
    
    override func sendAction() {
        super.sendAction()
        
        // prevent from executing multiple times
        navigationItem.rightBarButtonItem?.action = nil
        
        let resetActionIfFailed = {
            self.navigationItem.rightBarButtonItem?.action = #selector(IBBSPostViewController.sendAction)
        }

        blurTextEditor()
        
        if getHTML().ausTrimHtmlInWhitespaceAndNewlineCharacterSet().isEmpty {
            configureAlertController()
            return
        }
        
        shouldShowKeyboard = false
        
        let key = IBBSLoginKey()
        
        guard key.isValid else {
            IBBSContext.login(completion: { 
                self.sendAction()
            })
            return
        }
        
        let nodeId  = contentsArrayOfPostArticle[nodeID] as! Int
        let title   = contentsArrayOfPostArticle[articleTitle] as! String
        let content = getHTML()!
                
        APIClient.defaultClient.post(key.uid, nodeID: nodeId, content: content, title: title, token: key.token, success: { (json) -> Void in
            
            let model = IBBSModel(json: json)
            
            if model.success { //post successfully
                
                NSNotificationCenter.defaultCenter().postNotificationName(kShouldReloadDataAfterPosting, object: nil)
                
                self.dismissViewControllerAnimated(true , completion: nil)
                
                IBBSToast.make(model.message, interval: TIME_OF_TOAST_OF_POST_SUCCESS)
                
            } else {
                IBBSToast.make(model.message, interval: TIME_OF_TOAST_OF_POST_FAILED)
                
                resetActionIfFailed()
                
                executeAfterDelay(1.2, completion: {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
            
        }) { (error) -> Void in
            DEBUGLog(error)
            IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
            
            resetActionIfFailed()
        }
    }
    
    private func cancelAction() {
        blurTextEditor()
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    private func post() {
        
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
