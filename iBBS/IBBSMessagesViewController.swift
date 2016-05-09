//
//  IBBSMessagesViewController.swift
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
import SnapKit
import SwiftyJSON


class IBBSMessagesViewController: IBBSBaseViewController {
    
    private var messageArray: [JSON]!
    private var messageContent: JSON!
    private var draggableBackground: DraggableViewBackground!
    private var messageCard: DraggableView!
    private var replyCard: DraggableView!
    private var currentSenderUserID: Int!
    private var currentSenderUsername: String!
    private var currentSenderUserAvatarUrl: NSURL!
    private var replyCardTextViewPlaceholder: String!
    private var keyboardHeight: CGFloat!
    
    private lazy var topView: UIView? = {
        return UIApplication.topMostViewController?.view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        navigationItem.title = MESSAGES
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cornerActionButton?.hidden = true
        
        sendRequest()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // force device to portrait mode
        if UIInterfaceOrientation.Portrait.isPortrait {
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeRight
    }
    
    private func sendRequest() {
        
        IBBSContext.loginIfNeeded(alertMessage: LOGIN_TO_READ_MESSAGE) {
            
            // after login, the key has been saved, so here get it.
            let key = IBBSLoginKey()
            
            APIClient.defaultClient.getMessages(key.uid, token: key.token, success: { (json ) -> Void in
                
                self.messageArray = json.arrayValue
                self.tableView.reloadData()
                
                }, failure: { (error ) -> Void in
                    DEBUGLog(error)
                    IBBSToast.make(SERVER_ERROR, delay: 0, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
            })
        }
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        guard let cells = tableView?.visibleCells as? [IBBSMessageTableViewCell] else { return }
        
        _ = cells.map() {
            if $0.isRead { $0.isMessageRead?.changeImageColor(CUSTOM_THEME_COLOR.lighterColor(0.7)) }
        }
    }
    
    @objc private func removeViews() {
        draggableBackground?.removeFromSuperview()
    }
    
    private func configureDraggableView() {
        let blur = UIBlurEffect(style: .Light)
        draggableBackground = DraggableViewBackground(effect: blur)
        draggableBackground.alpha = 0.96
        draggableBackground.allCards[0].delegate = self
        draggableBackground.backgroundColor = UIColor.clearColor()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(removeViews))
        draggableBackground.addGestureRecognizer(gesture)
    }
    
    private func configureTableView() {
        tableView.registerNib(UINib(nibName: String(IBBSMessageTableViewCell), bundle: nil), forCellReuseIdentifier: String(IBBSMessageTableViewCell))
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    private func addDraggableViewWithAnimation(duration duration: NSTimeInterval = 0.1) {
        
        guard let topView = topView else { return }
        
        draggableBackground.transform = CGAffineTransformMakeScale(0.01, 0.01)
        topView.addSubview(draggableBackground)
        draggableBackground.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        UIView.animateWithDuration(duration) {
            self.draggableBackground.transform = CGAffineTransformIdentity
        }
    }
    
    private func getMessageContent(messageID: AnyObject, indexPath: NSIndexPath, completion: (() -> Void)?) {
        
        let key = IBBSLoginKey()
        
        guard key.isValid else { return }
        
        APIClient.defaultClient.readMessage(key.uid, token: key.token, msgID: messageID, success: { (json) -> Void in
            
            self.messageContent = json
            
            guard IBBSModel(json: json).success else { return }
            
            // read successfully
            
            completion?()
            
            guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? IBBSMessageTableViewCell else { return }
            
            cell.isMessageRead.image = UIImage(named: "message_have_read")
            
        }) { (error) -> Void in
            DEBUGLog(error)
        }
    }
    
    private func setMessageContent(avatarUrl: NSURL, isAdmin: Bool) {
        
        let model = IBBSReadMessageModel(json: messageContent)
        
        //        let title = model.title
        //        let username = model.username
        
        messageCard = draggableBackground.allCards[0]
        messageCard.content.text = model.content
        messageCard.avatar.kf_setImageWithURL(avatarUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        
        if !isAdmin {
            messageCard.avatar.backgroundColor = UIColor.blackColor()
            messageCard.avatar.image = UIImage(named: "administrator")
        }
    }
    
    // MARK: - table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messageArray != nil {
            return messageArray.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(String(IBBSMessageTableViewCell)) as? IBBSMessageTableViewCell {
            if let array = messageArray {
                let json = array[indexPath.row]
                cell.loadDataToCell(json)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: - table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let array = messageArray else { return }
        
        configureDraggableView()
        addDraggableViewWithAnimation()
        
        let model = IBBSMessageModel(json: array[indexPath.row])
        
        currentSenderUsername = model.sender
        currentSenderUserID = model.senderUid
        currentSenderUserAvatarUrl = model.avatarUrl
        
        getMessageContent(model.id, indexPath: indexPath, completion: {
            self.setMessageContent(self.currentSenderUserAvatarUrl, isAdmin: model.isAdministrator)
        })
    }
    
    
    // MARK: - refresh
    override func refreshData(){
        super.refreshData()
        
        sendRequest()

        executeAfterDelay(1.3) {
            self.gearRefreshControl.endRefreshing()
        }
    }
}


extension IBBSMessagesViewController: DraggableViewDelegate {
    
    // MARK: - reply message
    
    private func readyToReplyMessage() {
        
        let key = IBBSLoginKey()
        
        guard key.isValid else { return }
        
        let receiver_uid = currentSenderUserID
        let title = "@\(currentSenderUsername)"
        let content = (replyCard.content.text).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: replyCardTextViewPlaceholder))
        
        guard !content.isEmpty else {
            
            let alert = UIAlertController(title: "", message: YOU_HAVENOT_WROTE_ANYTHING, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: GOT_IT, style: .Cancel, handler: { (_) -> Void in
                self.showReplyCardAgainIfSomethingWrong()
            })
            
            alert.addAction(okAction)
            
            executeAfterDelay(1, completion: {
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
            return
        }
        
        APIClient.defaultClient.replyMessage(key.uid, token: key.token, receiver_uid: receiver_uid, title: title, content: content, success: { (json) -> Void in
            
            let model = IBBSModel(json: json)
            
            if model.success {
                // send successfully
                IBBSToast.make(REPLY_SUCCESSFULLY, delay: 0, interval: TIME_OF_TOAST_OF_REPLY_SUCCESS)
                
            } else {
                // failed
                let alert = UIAlertController(title: REPLY_FAILED, message: model.message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
                let continueAction = UIAlertAction(title: TRY_AGAIN, style: .Default, handler: { (_ ) -> Void in
                    self.showReplyCardAgainIfSomethingWrong()
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
    
    // MARK: - configure reply card
    private func removeViewsWithDelay() {
        executeAfterDelay(0.5) {
            self.removeViews()
        }
    }
    
    private func showReplyCardAgainIfSomethingWrong() {
        configureDraggableView()
        replyCard = draggableBackground?.allCards.first
        configureReplyCard()
        addDraggableViewWithAnimation()
    }
    
    private func performAfterSwiping(card card: UIView, left: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        if SWIPE_LEFT_TO_CANCEL_RIGHT_TO_CONTINUE == left {
            DEBUGLog("swiped left")
            
            /**
             *  messageCard and replyCard may nil.
             e.g: you didn't select any cell after getting list of message,
             */
            if card == messageCard ?? false {
                removeViewsWithDelay()
            }
            else if card == replyCard ?? false {
                let replyContentTempText = replyCard?.content?.text
                
                let alert = UIAlertController(title: "", message: ARE_YOU_SURE_TO_GIVE_UP, preferredStyle: .Alert)
                let continueAction = UIAlertAction(title: BUTTON_CONTINUE, style: .Default, handler: { (_) -> Void in
                    self.removeViews()
                    self.showReplyCardAgainIfSomethingWrong()
                    self.replyCard.content?.text = replyContentTempText
                })
                let cancelAction = UIAlertAction(title: BUTTON_GIVE_UP, style: .Cancel, handler: { _ in
                    self.removeViews()
                })
                
                alert.addAction(continueAction)
                alert.addAction(cancelAction)
                
                executeAfterDelay(0.5, completion: {
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }
        } else {
            
            DEBUGLog("swiped right")
            if card == messageCard {
                
                removeViews()
                configureDraggableView()
                addDraggableViewWithAnimation(duration: 0.5)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IBBSMessagesViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IBBSMessagesViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
                
                replyCard = draggableBackground?.allCards.first
                
                configureReplyCard()
            }
            else if card == replyCard {
                DEBUGLog("reply card swiping right")
                removeViewsWithDelay()
                readyToReplyMessage()
            }
            
        }
    }
    
    private func configureReplyCard() {
        
        replyCard?.delegate = self
        
        replyCard.avatar.snp_remakeConstraints { (make) in
            make.width.height.equalTo(24)
            make.top.equalTo(4)
            make.centerX.equalTo(0)
        }
        replyCard.avatar.layer.cornerRadius = 12.0
        replyCard.avatar.kf_setImageWithURL(currentSenderUserAvatarUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        
        replyCard.content.snp_updateConstraints { (make) in
            make.top.equalTo(35)
        }
        replyCard.content.font = UIFont.systemFontOfSize(15)
        replyCard.content.textAlignment = NSTextAlignment.Left
        replyCard.content.editable = true
        replyCardTextViewPlaceholder = " @\(currentSenderUsername):  "
        replyCard.content.text = replyCardTextViewPlaceholder
        
        let separator = UIView()
        separator.backgroundColor = UIColor(red:0.874, green:0.913, blue:0.956, alpha:1)
        separator.layer.shadowRadius = 5
        separator.layer.shadowOpacity = 0.2
        separator.layer.shadowOffset = CGSizeMake(1, 1)
        replyCard.addSubview(separator)
        separator.snp_makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(34)
            make.height.equalTo(0.5)
        }
        
        executeAfterDelay(0.5) {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.replyCard.content.becomeFirstResponder()
                self.replyCard.frame.size.height = UIScreen.height - 50 - 8 - self.keyboardHeight
                self.replyCard.content.frame.size.height = UIScreen.height - 50 - 45 - 8 - self.keyboardHeight
            })
        }
    }
    
    // MARK: - draggable view delegate
    func cardSwipedLeft(card: UIView) {
        performAfterSwiping(card: card, left: true)
    }
    
    func cardSwipedRight(card: UIView) {
        performAfterSwiping(card: card, left: false)
    }
    
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
        DEBUGLog("keyboardHeight: \(kbHeight), duration: \(duration)")
        keyboardHeight = kbHeight
        
        replyCard?.frame.size.height = UIScreen.height - 50 - 8 - kbHeight
        replyCard?.content.frame.size.height = UIScreen.height - 50 - 45 - 8 - kbHeight
    }
    
}

