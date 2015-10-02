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
    struct Mainstoryboard {
        static let cellNibName = "IBBSMessageTableViewCell"
        static let cellIdentifier = "iBBSMessageTableViewCell"
    }
    
    private var messageArray: [JSON]!
    private var messageContent: JSON!
    var draggableBackground: DraggableViewBackground!
    var messageCard: DraggableView!
    var replyCard: DraggableView!
    var insertBlurView: UIVisualEffectView!
    var infoLabel: UILabel!
    var currentSenderUserID: String!
    var currentSenderUsername: String!
    var currentSenderUserAvatarUrl: NSURL!
    
    var keyboardHeight = CGFloat() {
        didSet{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.navigationItem.title = MESSAGES
        self.configureInfoLabel()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.sendRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func sendRequest(){
        IBBSContext.sharedInstance.isLogin(){ (isLogin) -> Void in
            if isLogin {
                let loginData = IBBSContext.sharedInstance.getLoginData()
                let userID = loginData?["uid"].stringValue
                let token = loginData?["token"].stringValue
                
                APIClient.sharedInstance.getMessages(userID!, token: token!, success: { (json ) -> Void in
                    print(json)
                    if json == nil {
                        self.infoLabel.hidden = false
                        //                        UIApplication.topMostViewController()?.view.makeToast(message: "There is no message yet...", duration: 3, position: HRToastPositionCenter)
                    }else{
                        self.infoLabel.hidden = true
                        
                    }
                    self.messageArray = json.arrayValue
                    self.tableView.reloadData()
                    
                    }, failure: { (error ) -> Void in
                        print(error)
                        self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                })
            }else{
                
                let loginAlertController = UIAlertController(title: "", message: LOGIN_TO_READ_MESSAGE, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: BUTTON_OK, style: .Default, handler: { (_) -> Void in
                    let vc = IBBSEffectViewController()
                    vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                    self.presentViewController(vc, animated: true, completion: nil)
                    
                    IBBSContext.sharedInstance.login(cancelled: {
                        vc.dismissViewControllerAnimated(true , completion: nil)
                        }, completion: {
                            vc.dismissViewControllerAnimated(true, completion: nil)
                            
                            self.automaticPullingDownToRefresh()
                            self.sendRequest()
                            //                self.tableView.reloadData()
                    })
                })
                let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel , handler: nil)
                loginAlertController.addAction(cancelAction)
                loginAlertController.addAction(okAction)
                self.presentViewController(loginAlertController, animated: true, completion: nil)
            }
            
            
        }
        
    }
    
    func removeViews(){
        self.draggableBackground.removeFromSuperview()
        self.insertBlurView.removeFromSuperview()
    }
    
    func configureInfoLabel(){
        infoLabel = UILabel(frame: CGRectMake(0, kScreenHeight / 3, kScreenWidth, 20))
        infoLabel.text = NO_MESSAGE_YET
        infoLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(infoLabel)
        infoLabel.hidden = true
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
        tableView.registerNib(UINib(nibName: Mainstoryboard.cellNibName, bundle: nil), forCellReuseIdentifier: Mainstoryboard.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    
    private func addDraggableViewWithAnimation(){
        //        let rootView = self.parentViewController?.parentViewController?.view
        //        UIView.transitionWithView(rootView!, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
        //            rootView?.addSubview(self.draggableBackground)
        //
        //            }, completion: nil)
        //        self.parentViewController?.parentViewController?.view.addSubview(self.draggableBackground)
        draggableBackground.transform = CGAffineTransformMakeScale(0.01, 0.01)
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            UIApplication.topMostViewController()?.view.addSubview(self.draggableBackground)
            self.draggableBackground.transform = CGAffineTransformIdentity
            
            }) { (_) -> Void in
        }
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
        messageCard.avatar.kf_setImageWithURL(avatarUrl)
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
        if let cell = tableView.dequeueReusableCellWithIdentifier(Mainstoryboard.cellIdentifier) as? IBBSMessageTableViewCell {
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
            self.addDraggableViewWithAnimation()
            
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
    private func removeViewsWithDelay(){
        let delayInSeconds: Double = 0.5
        let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
        let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.removeViews()
        })
        
    }
    
    private func performAfterSwiping(card card: UIView, left: Bool) {
        if SWIPE_LEFT_TO_CANCEL_RIGHT_TO_CONTINUE == left {
            print("swiped left")
            self.removeViewsWithDelay()
        }else{
            print("swiped right")
            if card == messageCard {
                self.draggableBackground.loadCards()
                self.configureReplyCard()
            }
            print("##############################")
            print(card)
            print("##############################")

            if card == replyCard {
                print("reply card swiping right")
                self.removeViewsWithDelay()
            }
            
            
        }
    }
    
    private func configureReplyCard(){
        replyCard = self.draggableBackground?.allCards.last
        replyCard.delegate = self
        let cardWidth = replyCard.frame.size.width
        let cardHeight = replyCard.frame.size.height
        
        //            replyCard.avatar.frame = CGRectMake(cardWidth - 28, 4, 24, 24)
        replyCard.avatar.frame = CGRectMake(cardWidth / 2 - 12, 4, 24, 24)
        replyCard.avatar.layer.cornerRadius = 12.0
        replyCard.avatar.kf_setImageWithURL(self.currentSenderUserAvatarUrl)
        
        
        replyCard.content.frame = CGRectMake(16, 35, cardWidth - 32, cardHeight - 45)
        replyCard.content.font = UIFont.systemFontOfSize(15)
        //            replyCard.content.layer.cornerRadius = 3
        //            replyCard.content.layer.borderWidth = 0.5
        //            replyCard.content.layer.borderColor = UIColor(red:0.69, green:0.73, blue:0.77, alpha:1).CGColor
        replyCard.content.textAlignment = NSTextAlignment.Left
        replyCard.content.editable = true
        
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
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.replyCard.content.becomeFirstResponder()
                
                self.replyCard.frame = CGRectMake(16, 50, kScreenWidth - 32, kScreenHeight - 50 - 8 - self.keyboardHeight)
                self.replyCard.content.frame = CGRectMake(16, 35, cardWidth - 32, kScreenHeight - 50 - 45 - 8 - self.keyboardHeight)
                
            })
        })
        
        
    }
    
    // MARK: - draggable view delegate
    func cardSwipedLeft(card: UIView) {
        self.performAfterSwiping(card: card, left: true)
        print(card)
    }
    
    func cardSwipedRight(card: UIView) {
        self.performAfterSwiping(card: card, left: false)
        print(card)
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
        replyCard.frame = CGRectMake(16, 50, kScreenWidth - 32, kScreenHeight - 50 - 8 - kbHeight)
        replyCard.content.frame = CGRectMake(16, 35, replyCard.frame.width - 32, kScreenHeight - 50 - 45 - 8 - kbHeight)
    }
    
}

