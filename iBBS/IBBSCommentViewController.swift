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


protocol IBBSCommentViewControllerDelegate {
    func refreshData()
}

class IBBSCommentViewController: IBBSEditorBaseViewController {
    
    var post_id = Int()
    
    var delegate: IBBSCommentViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelAction))
        navigationController?.navigationBar.translucent = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        executeAfterDelay(0.3) {
            self.focusTextEditor()
        }
    }
    
    @objc private func cancelAction() {
        
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

            executeAfterDelay(0.5, completion: {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    override func sendAction() {
        super.sendAction()
        
        navigationItem.rightBarButtonItem?.action = nil
        
        let resetActionIfFailed = {
            self.navigationItem.rightBarButtonItem?.action = #selector(self.sendAction)
        }
        
        blurTextEditor()
        
        if getHTML().ausTrimHtmlInWhitespaceAndNewlineCharacterSet().isEmpty {
            configureAlertController()
            return
        }
        
        let content = getHTML()
        
        let key = IBBSLoginKey()
        
        guard key.isValid else {
            IBBSContext.login(completion: { 
                self.sendAction()
            })
            return
        }
                
        APIClient.defaultClient.comment(key.uid, postID: post_id, content: content, token: key.token, success: { (json) -> Void in
            
            let model = IBBSModel(json: json)

            if model.success { //comment successfully
                
                IBBSToast.make(model.message, interval: TIME_OF_TOAST_OF_COMMENT_SUCCESS)
                
                self.dismissViewControllerAnimated(true , completion: {
                    self.delegate?.refreshData()
                })

            } else {
                IBBSToast.make(model.message, interval: TIME_OF_TOAST_OF_COMMENT_FAILED)
                
                resetActionIfFailed()
                
                executeAfterDelay(0.5, completion: {
                    self.focusTextEditor()
                })
            }
            
        }) { (error ) -> Void in
            DEBUGLog(error)
            
            resetActionIfFailed()
            
            IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
        }
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
