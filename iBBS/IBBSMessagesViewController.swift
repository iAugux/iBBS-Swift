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
    
    private var alertController: UIAlertController!
    private var messageArray: [JSON]!
    private var messageContent: JSON!
    var draggableBackground: DraggableViewBackground!
    var insertBlurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        //        self.automaticPullingDownToRefresh()
        self.navigationItem.title = "Messages"
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.sendRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sendRequest(){
        if IBBSContext.sharedInstance.isLogin() {
            let loginData = IBBSContext.sharedInstance.getLoginData()
            let userID = loginData?["uid"].stringValue
            let token = loginData?["token"].stringValue

            APIClient.sharedInstance.getMessages(userID!, token: token!, success: { (json ) -> Void in
                print(json)
                self.messageArray = json.arrayValue
                self.tableView.reloadData()
                
                }, failure: { (error ) -> Void in
                    print(error)
            })
            
        }else{
            self.alertController = UIAlertController()
            IBBSContext.sharedInstance.login(alertController, presentingVC: self, completion: {
                self.automaticPullingDownToRefresh()
                self.sendRequest()
                //                self.tableView.reloadData()
                
            })
        }
    }
    
    func removeViews(){
        draggableBackground.removeFromSuperview()
        insertBlurView.removeFromSuperview()
    }
    
    private func configureDraggableViews(){
        
        draggableBackground = DraggableViewBackground(frame: self.view.frame)
        draggableBackground.backgroundColor = UIColor.clearColor()
        insertBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        insertBlurView.frame = draggableBackground.bounds
        insertBlurView.alpha = 0.9
        let gesture = UITapGestureRecognizer(target: self, action: "removeViews")
        draggableBackground.addGestureRecognizer(gesture)
        self.parentViewController?.parentViewController?.view.addSubview(insertBlurView)
        
    }
    
    private func configureTableView(){
        tableView.registerNib(UINib(nibName: Mainstoryboard.cellNibName, bundle: nil), forCellReuseIdentifier: Mainstoryboard.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }

    
    func addDraggableViewWithAnimation(){
//        let rootView = self.parentViewController?.parentViewController?.view
//        UIView.transitionWithView(rootView!, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//            rootView?.addSubview(self.draggableBackground)
//            
//            }, completion: nil)
//        self.parentViewController?.parentViewController?.view.addSubview(self.draggableBackground)
        draggableBackground.transform = CGAffineTransformMakeScale(0.01, 0.01)
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.parentViewController?.parentViewController?.view.addSubview(self.draggableBackground)
            self.draggableBackground.transform = CGAffineTransformIdentity

            }) { (_) -> Void in
        }
    }
    
    func getMessageContent(messageID: AnyObject, indexPath: NSIndexPath, completion: (() -> Void)?){
        let loginData = IBBSContext.sharedInstance.getLoginData()
        let userID = loginData?["uid"].stringValue
        let token = loginData?["token"].stringValue

        APIClient.sharedInstance.readMessage(userID!, token: token!, msgID: messageID, success: { (json ) -> Void in
            print(json)
            self.messageContent = json
            print(self.messageContent)
            if json["code"].intValue == 1 {
                // read successfully
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? IBBSMessageTableViewCell {
                    cell.isMessageRead.image = UIImage(named: "message_read_1")
                }
                if let completionHandler = completion {
                    completionHandler()
                }
            }
            }) { (error ) -> Void in
                print(error)
        }
    }
    
    func setMessageContent(avatarUrl: NSURL,isAdmin: Bool){
        let content = messageContent["msg"]["content"].stringValue
//        let title = messageContent["title"].stringValue
//        let username = messageContent["msg"]["username"].stringValue
        let messageCard = self.draggableBackground.allCards[0]
        messageCard.information.text = content
        messageCard.avatar.kf_setImageWithURL(avatarUrl)
        if !isAdmin {
            messageCard.avatar.backgroundColor = UIColor.blackColor()
            messageCard.avatar.image = UIImage(named: "Administrator")
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
            let avatarUrl = NSURL(string: json["sender_avatar"].stringValue)
            let isAdministrator = json["type"].boolValue
            self.getMessageContent(messageID, indexPath: indexPath, completion: {
                print(json)
                self.setMessageContent(avatarUrl!, isAdmin: isAdministrator)
                self.addDraggableViewWithAnimation()
                
            })
            
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
    func cardSwipedLeft(card: UIView) {
        print("llllll")
    }
    
    func cardSwipedRight(card: UIView) {
        print("rrrrrr")
    }
}

