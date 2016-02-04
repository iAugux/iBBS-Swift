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
import SwiftyJSON


class IBBSMessagesViewController: IBBSBaseViewController {
    
    private var messageArray: [JSON]!
    private var messageContent: JSON!
    var draggableBackground: DraggableViewBackground!
    var messageCard: DraggableView!
    var replyCard: DraggableView!
    var insertBlurView: UIVisualEffectView!
    var currentSenderUserID: String!
    var currentSenderUsername: String!
    var currentSenderUserAvatarUrl: NSURL!
    var replyCardTextViewPlaceholder: String!
    var keyboardHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.navigationItem.title = MESSAGES
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sendRequest()
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
    
    func sendRequest(){
        IBBSContext.sharedInstance.isTokenLegal(){ (isTokenLegal) -> Void in
            if isTokenLegal {
                let loginData = IBBSContext.sharedInstance.getLoginData()
                let userID = loginData?["uid"].stringValue
                let token = loginData?["token"].stringValue
                
                APIClient.sharedInstance.getMessages(userID!, token: token!, success: { (json ) -> Void in
                    print(json)
                   
                    self.messageArray = json.arrayValue
                    self.tableView.reloadData()
                    
                    }, failure: { (error ) -> Void in
                        print(error)
                        self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                })
            }else{
                
                self.presentLoginViewControllerIfNotLogin(alertMessage: LOGIN_TO_READ_MESSAGE, completion: { () -> Void in
                    self.automaticPullingDownToRefresh()
                    self.sendRequest()
                })
            }
            
            
        }
        
    }
    
    override func updateTheme() {
        super.updateTheme()
        if let cells = self.tableView?.visibleCells as? [IBBSMessageTableViewCell] {
            for index in 0 ..< cells.count {
                let cell = cells[index]
                if cell.isRead == 0 {
                    cell.isMessageRead?.changeColorForImageOfImageView(CUSTOM_THEME_COLOR.lighterColor(0.7))
                }
            }
        }
    }
    
    func removeViews(){
        self.draggableBackground?.removeFromSuperview()
        self.insertBlurView?.removeFromSuperview()
    }
    
    private func configureDraggableViews(){
        
        draggableBackground = DraggableViewBackground(frame: self.view.frame)
        draggableBackground.allCards[0].delegate = self
        draggableBackground.backgroundColor = UIColor.clearColor()
        insertBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        insertBlurView.frame = draggableBackground.bounds
        insertBlurView.alpha = 0.96
        let gesture = UITapGestureRecognizer(target: self, action: "removeViews")
        draggableBackground.addGestureRecognizer(gesture)
        UIApplication.topMostViewController()?.view.addSubview(insertBlurView)
        
    }
    
    private func configureTableView(){
        tableView.registerNib(UINib(nibName: MainStoryboard.NibIdentifiers.messageCell, bundle: nil), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.messageCell)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    
    private func addDraggableViewWithAnimation(){
        
        draggableBackground.transform = CGAffineTransformMakeScale(0.01, 0.01)
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            UIApplication.topMostViewController()?.view.addSubview(self.draggableBackground)
            self.draggableBackground.transform = CGAffineTransformIdentity
            
            }) { (_) -> Void in
                
        }
    }
    
    override func cornerActionButtonDidTap(){
        super.cornerActionButtonDidTap()
        print("editing message...")
        // TODO: - send message
        
    }
    
    private func getMessageContent(messageID: AnyObject, indexPath: NSIndexPath, completion: (() -> Void)?){
        if let loginData = IBBSContext.sharedInstance.getLoginData() {
            let userID = loginData["uid"].stringValue
            let token = loginData["token"].stringValue
            
            APIClient.sharedInstance.readMessage(userID, token: token, msgID: messageID, success: { (json ) -> Void in
                print(json)
                self.messageContent = json
                print(self.messageContent)
                if json["code"].intValue == 1 {
                    // read successfully
                    if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? IBBSMessageTableViewCell {
                        cell.isMessageRead.image = UIImage(named: "message_have_read")
                    }
                    if let completionHandler = completion {
                        completionHandler()
                    }
                }
                }) { (error ) -> Void in
                    print(error)
            }
            
        }
    }
    
    private func setMessageContent(avatarUrl: NSURL,isAdmin: Bool){
        let content = messageContent["msg"]["content"].stringValue
        //        let title = messageContent["title"].stringValue
        //        let username = messageContent["msg"]["username"].stringValue
        messageCard = self.draggableBackground.allCards[0]
        messageCard.content.text = content
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
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.messageCell) as? IBBSMessageTableViewCell {
            if let array = self.messageArray {
                let json = array[indexPath.row]
                cell.loadDataToCell(json)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: - table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.configureDraggableViews()
        self.addDraggableViewWithAnimation()
        if let array = self.messageArray {
            let json = array[indexPath.row]
            let messageID = json["id"].stringValue
            self.currentSenderUsername = json["sender"].stringValue
            self.currentSenderUserID = json["sender_uid"].stringValue
            self.currentSenderUserAvatarUrl = NSURL(string: json["sender_avatar"].stringValue)
            let isAdministrator = json["type"].boolValue
            self.getMessageContent(messageID, indexPath: indexPath, completion: {
                print(json)
                self.setMessageContent(self.currentSenderUserAvatarUrl, isAdmin: isAdministrator)
                
            })
            
        } else {
            print("lost network")
        }
        
    }
    
    
    // MARK: - refresh
    func refreshData(){
        
        self.sendRequest()
        let refreshInSeconds = 1.3
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            //            self.tableView.reloadData()
            
            self.gearRefreshControl.endRefreshing()
        }
        
    }
}


extension IBBSMessagesViewController: DraggableViewDelegate {
    
    // MARK: - reply message
    private func readyToReplyMessage() {
        if let info = IBBSContext.sharedInstance.getLoginData() {
            let uid = info["uid"].stringValue
            let token = info["token"].stringValue
            let receiver_uid = self.currentSenderUserID
            let title = "@\(self.currentSenderUsername)"
            let content = (self.replyCard.content.text).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: self.replyCardTextViewPlaceholder))
            if content.utf8.count == 0 {
                let alert = UIAlertController(title: "", message: YOU_HAVENOT_WROTE_ANYTHING, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: GOT_IT, style: .Cancel, handler: { (_) -> Void in
                    self.showReplyCardAgainIfSomethingWrong()
                })
                
                alert.addAction(okAction)
                let delayInSeconds: Double = 1
                let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                dispatch_after(popTime, dispatch_get_main_queue(), {
                    self.presentViewController(alert, animated: true, completion: nil)
                })

                return
            }
            
            APIClient.sharedInstance.replyMessage(uid, token: token, receiver_uid: receiver_uid, title: title, content: content, success: { (json) -> Void in
                print(json)
                // send successfully
                if json["code"].intValue == 1 {
                    UIApplication.topMostViewController()?.view.makeToast(message: REPLY_SUCCESSFULLY, duration: TIME_OF_TOAST_OF_REPLY_SUCCESS, position: HRToastPositionTop)
                    
                }else { // failed
                    let msg = json["msg"].stringValue
                    let alert = UIAlertController(title: REPLY_FAILED, message: msg, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
                    let continueAction = UIAlertAction(title: TRY_AGAIN, style: .Default, handler: { (_ ) -> Void in
                        print("try again")
                        self.showReplyCardAgainIfSomethingWrong()
                    })
                    
                    alert.addAction(cancelAction)
                    alert.addAction(continueAction)
                    let delayInSeconds: Double = 1
                    let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
                    dispatch_after(popTime, dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })

                }
                }, failure: { (error ) -> Void in
                    print(error)
            })
            
        }
        
    }
    
    // MARK: - configure reply card
    private func removeViewsWithDelay(){
        let delayInSeconds: Double = 0.5
        let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
        let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.removeViews()
        })
        
    }
    
    private func showReplyCardAgainIfSomethingWrong() {
        self.configureDraggableViews()
        self.replyCard = self.draggableBackground?.allCards.first
        self.configureReplyCard()
        self.addDraggableViewWithAnimation()
    }
    
    private func performAfterSwiping(card card: UIView, left: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

        if SWIPE_LEFT_TO_CANCEL_RIGHT_TO_CONTINUE == left {
            print("swiped left")
            
            /**
            *  messageCard and replyCard may nil.
                e.g: you didn't select any cell after getting list of message,
            */
            if card == messageCard ?? false {
                self.removeViewsWithDelay()
            }
            else if card == replyCard ?? false {
                let replyContentTempText = self.replyCard?.content?.text

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
                let delayInSeconds: Double = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delayInSeconds))
                dispatch_after(popTime, dispatch_get_main_queue(), {
                    self.presentViewController(alert, animated: true, completion: nil)
                })

            }
        }else{
            print("swiped right")
            if card == messageCard {
                self.draggableBackground.loadCards()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
                
                replyCard = self.draggableBackground?.allCards.last

                self.configureReplyCard()
            }
            else if card == replyCard {
                print("reply card swiping right")
                self.removeViewsWithDelay()
                self.readyToReplyMessage()
            }
            
        }
    }
    
    private func configureReplyCard(){
        replyCard?.delegate = self
        let cardWidth = replyCard.frame.size.width
        let cardHeight = replyCard.frame.size.height
        
        //            replyCard.avatar.frame = CGRectMake(cardWidth - 28, 4, 24, 24)
        replyCard.avatar.frame = CGRectMake(cardWidth / 2 - 12, 4, 24, 24)
        replyCard.avatar.layer.cornerRadius = 12.0
        replyCard.avatar.kf_setImageWithURL(self.currentSenderUserAvatarUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        
        replyCard.content.frame = CGRectMake(16, 35, cardWidth - 32, cardHeight - 45)
        replyCard.content.font = UIFont.systemFontOfSize(15)
        //            replyCard.content.layer.cornerRadius = 3
        //            replyCard.content.layer.borderWidth = 0.5
        //            replyCard.content.layer.borderColor = UIColor(red:0.69, green:0.73, blue:0.77, alpha:1).CGColor
        replyCard.content.textAlignment = NSTextAlignment.Left
        replyCard.content.editable = true
        replyCardTextViewPlaceholder = " @\(self.currentSenderUsername):  "
        replyCard.content.text = replyCardTextViewPlaceholder
        
        let separator = UIView(frame: CGRectMake(16, 34, cardWidth - 32, 0.5))
        separator.backgroundColor = UIColor(red:0.874, green:0.913, blue:0.956, alpha:1)
        separator.layer.shadowRadius = 5
        separator.layer.shadowOpacity = 0.2
        separator.layer.shadowOffset = CGSizeMake(1, 1)
        replyCard.addSubview(separator)
        
        let delayInSeconds: Double = 0.5
        let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
        let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
        dispatch_after(popTime, dispatch_get_main_queue(), {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.replyCard.content.becomeFirstResponder()
                
                self.replyCard.frame = CGRectMake(16, 50, UIScreen.screenWidth() - 32, UIScreen.screenHeight() - 50 - 8 - self.keyboardHeight)
                self.replyCard.content.frame = CGRectMake(16, 35, cardWidth - 32, UIScreen.screenHeight() - 50 - 45 - 8 - self.keyboardHeight)
            })
        })
        
        
    }
    
    // MARK: - draggable view delegate
    func cardSwipedLeft(card: UIView) {
        self.performAfterSwiping(card: card, left: true)
    }
    
    func cardSwipedRight(card: UIView) {
        self.performAfterSwiping(card: card, left: false)
    }
    
    // MARK: - keyboard notification
    func keyboardWillShow(notification: NSNotification) {
        guard let kbSizeValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        animateToKeyboardHeight(kbSizeValue.CGRectValue().height, duration: kbDurationNumber.doubleValue)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        animateToKeyboardHeight(0, duration: kbDurationNumber.doubleValue)
    }
    
    func animateToKeyboardHeight(kbHeight: CGFloat, duration: Double) {
        print("keyboardHeight: \(kbHeight), duration: \(duration)")
        self.keyboardHeight = kbHeight
        
//        let delayInSeconds: Double = 0.2
//        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delayInSeconds))
//        dispatch_after(popTime, dispatch_get_main_queue(), {
//            UIView.animateWithDuration(duration) { () -> Void in
//                self.replyCard?.frame.size.height = UIScreen.screenHeight() - 50 - 8 - kbHeight
//                self.replyCard?.content.frame.size.height = UIScreen.screenHeight() - 50 - 45 - 8 - kbHeight
//            }
//        })
        
        self.replyCard?.frame.size.height = UIScreen.screenHeight() - 50 - 8 - kbHeight
        self.replyCard?.content.frame.size.height = UIScreen.screenHeight() - 50 - 45 - 8 - kbHeight
    }
    
}

