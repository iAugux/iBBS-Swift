//
//  IBBSMessagesViewController.swift
//  iBBS
//
//  Created by Augus on 9/16/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class IBBSMessagesViewController: IBBSBaseViewController {
    struct Mainstoryboard {
        static let cellNibName = "IBBSMessageTableViewCell"
        static let cellIdentifier = "iBBSMessageTableViewCell"
    }
    
    var alertController: UIAlertController!
    var messageArray: [JSON]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()

    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.sendRequest()
    }
    
    func sendRequest(){
        if IBBSContext.sharedInstance.isLogin() {
            if let userInfo = IBBSContext.sharedInstance.getLoginData() {
                let token = userInfo["token"].stringValue
                let userID = userInfo["uid"].stringValue
                APIClient.sharedInstance.getMessages(userID, token: token, success: { (json ) -> Void in
                    print(json)
                    self.messageArray = json.arrayValue
                    self.tableView.reloadData()
                    
                    }, failure: { (error ) -> Void in
                        print(error)
                })
            }
         }else{
            self.alertController = UIAlertController()
            IBBSContext.sharedInstance.login(alertController, presentingVC: self, completion: { () -> Void in
                
            })
//            self.automaticPullingDownToRefresh()
//
//            let delayInSeconds: Double = 0.6
//            let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
//            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delta)
//            dispatch_after(popTime, dispatch_get_main_queue(), {
//                self.tableView.reloadData()
//                self.gearRefreshControl.endRefreshing()
//                
//            })

        }
    }
    
    func configureTableView(){
        tableView.registerNib(UINib(nibName: Mainstoryboard.cellNibName, bundle: nil), forCellReuseIdentifier: Mainstoryboard.cellIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("desvc") as? BackgroundAnimationViewController {
            self.presentViewController(destinationVC, animated: true, completion: nil)
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
