//
//  IBBSChatViewController.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit

class IBBSChatViewController: UIViewController {
    
    var receiver: User!
    
    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.layer.cornerRadius = 5.0
            textView.backgroundColor = CUSTOM_THEME_COLOR.colorWithAlphaComponent(0.1)
        }
    }

    private var tempTextViewText: String!
    private var keyboardHeight: CGFloat!

    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(sendMessage)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = tempTextViewText
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func sendMessage() {
        
        textView?.resignFirstResponder()
        
        let key = IBBSLoginKey()
        
        guard key.isValid else { return }
        
        guard let receiver = receiver else { return }
        
        let doAgain = {
            executeAfterDelay(0.3) {
                self.textView?.becomeFirstResponder()
            }
        }
        
        let content = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "iAugus"))
        
        guard !content.isEmpty else {
            
            let alert = UIAlertController(title: "", message: YOU_HAVENOT_WROTE_ANYTHING, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: GOT_IT, style: .Cancel, handler: { (_) -> Void in
                doAgain()
            })
            
            alert.addAction(okAction)
            
            executeAfterDelay(1, completion: {
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
            return
        }
        
        let title = "@\(receiver.name)"
        
        APIClient.defaultClient.sendMessage(key.uid!, token: key.token!, receiver_uid: receiver.id, title: title, content: content, success: { (json) -> Void in
            
            let model = IBBSModel(json: json)
            
            if model.success {
                // send successfully
                
                self.navigationController?.popViewControllerAnimated(true)
                
                IBBSToast.make(SEND_SUCCESSFULLY, delay: 0, interval: TIME_OF_TOAST_OF_REPLY_SUCCESS)
                
            } else {
                // failed
                let alert = UIAlertController(title: SEND_FAILED, message: model.message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
                let continueAction = UIAlertAction(title: TRY_AGAIN, style: .Default, handler: { (_ ) -> Void in
                    doAgain()
                })
                
                alert.addAction(cancelAction)
                alert.addAction(continueAction)
                
                executeAfterDelay(1, completion: {
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }
            }, failure: { (error ) -> Void in
                DEBUGLog(error)
        })

    }
}


extension IBBSChatViewController {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        textView.resignFirstResponder()
    }
}


extension IBBSChatViewController {
    
    // MARK: - keyboard notification
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let kbSizeValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }

        animateToKeyboardHeight(kbSizeValue.CGRectValue().height, duration: kbDurationNumber.doubleValue)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        
        animateToKeyboardHeight(0, duration: kbDurationNumber.doubleValue)
    }
    
    private func animateToKeyboardHeight(kbHeight: CGFloat, duration: Double) {

        keyboardHeight = kbHeight
        
        textViewBottomConstraint?.constant = kbHeight + 12
    }

}