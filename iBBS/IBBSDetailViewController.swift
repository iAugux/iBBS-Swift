//
//  IBBSDetailViewController.swift
//  iBBS
//
//  Created by Augus on 9/3/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class IBBSDetailViewController: IBBSBaseViewController, UIGestureRecognizerDelegate {
    
    var json: JSON!
    var headerView: IBBSDetailHeaderView!
    var prototypeCell: IBBSReplyCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendRequest(page)
        pullUpToLoadmore()
        configureHeaderView()
        configureTableView()
        configureGesture()
//        configureCornerCommentButton()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Comment", style: .Plain, target: self, action: "commentAction")
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // TODO: - There is a bug! App will crash sometimes when set hidesBarsOnSwipe to true, but I don't know why
//        navigationController?.navigationBar.hidden = false
//        navigationController?.hidesBarsOnSwipe = true
//    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func cornerActionButtonDidTap() {
        DEBUGLog("commenting...")
        IBBSContext.sharedInstance.isTokenLegal(){ (isTokenLegal) -> Void in
            if isTokenLegal{
                let post_id = self.json["id"].stringValue
                if let vc = mainStoryboard.instantiateViewControllerWithIdentifier("iBBSCommentViewController") as? IBBSCommentViewController{
                    vc.post_id = post_id
                    let nav = UINavigationController(rootViewController: vc)
                    self.presentViewController(nav, animated: true, completion: nil)
                }
                
            }else {
                IBBSContext.sharedInstance.login(cancelled: nil, completion: {
                    self.cornerActionButtonDidTap()
                })
            }

        }
        
    }
    
    func configureTableView(){
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: MainStoryboard.NibIdentifiers.replyCell, bundle: nil), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.replyCell)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    
    func configureHeaderView(){
        let headerViewNib = NSBundle.mainBundle().loadNibNamed(MainStoryboard.NibIdentifiers.headerView, owner: self, options: nil)
        headerView = headerViewNib.first as! IBBSDetailHeaderView
        
        headerView.loadData(json)
        //                headerView.content.backgroundColor = UIColor.randomColor()
        let headerTitleLabelHeight = headerView.headerTitleLabel.ausReturnFrameSizeAfterResizingLabel().height
        let contentLabelHeight = headerView.content.ausReturnFrameSizeAfterResizingTextView().height
        let totalHeight = headerTitleLabelHeight + contentLabelHeight + 12 + 28 + 16 + 8 + 8
        headerView.setFrameHeight(totalHeight)
        //        let headerViewFittingSize = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        //        headerView.setFrameHeight(headerViewFittingSize.height)
        headerView.setNeedsUpdateConstraints()
        headerView.updateConstraintsIfNeeded()
        tableView.tableHeaderView = headerView
        navigationItem.title = headerView.nodeName
        
    }
    
    //    func customizeNavBar(color: UIColor, titleFont: UIFont, buttonFont: UIFont) {
    //
    //        UINavigationBar.appearance().tintColor = color
    //        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: color, NSFontAttributeName: titleFont]
    //        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: color, NSFontAttributeName: buttonFont], forState: UIControlState.Normal)
    //    }
    
    func sendRequest(page: Int) {
        APIClient.sharedInstance.getReplies(json["id"].stringValue, page: page, success: { (json) -> Void in
            if json == nil && page != 1 {
                UIApplication.topMostViewController()?.view?.makeToast(message: NO_MORE_DATA, duration: TIME_OF_TOAST_OF_NO_MORE_DATA, position: HRToastPositionCenter)
            }
            if json.type == Type.Array {
                if page == 1{
                    self.datasource = json.arrayValue
                    self.tableView.reloadData()
                }else {
                    let appendArray = json.arrayValue
                    self.datasource? += appendArray
                    self.tableView.reloadData()
                    DEBUGLog(self.datasource)
                }
            }
            }) { (error) -> Void in
                DEBUGLog(error)
                self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                
        }
    }
    
    // MARK: - configure gesture
    func configureGesture(){
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.enabled = true
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        if navigationController?.viewControllers.count == 1 {
    //            return false
    //        }
    //        return true
    //    }
    
    
    
    // MARK: - table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            return datasource.count
        }
        return 0
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.replyCell) as? IBBSReplyCell {
            let json = datasource[indexPath.row]
            cell.loadDataToCell(json)
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if datasource == nil || datasource.count == 0 {
            return NO_REPLY_YET
        }
        else if datasource.count == 1 {
            return "\(REPLY_COUNT) : 1"
        }
        return "\(REPLY_COUNTS) : \(datasource.count)"
        
    }
    
    // customize title for header in section
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            //           header.textLabel?.backgroundColor = UIColor.redColor()
            header.textLabel?.font = UIFont.systemFontOfSize(14)
        }
        
        
    }
    
    //    // customize title for header in section
    //    func titleForHeaderInSection() -> NSString? {
    //        if datasource == nil || datasource.count == 0 {
    //            return "No reply yet"
    //        }
    //        else if datasource.count == 1 {
    //            return "Reply : 1"
    //        }
    //        return "Replies : \(datasource.count)"
    //    }
    //
    //    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let text = titleForHeaderInSection()
    //        let labelSize = text!.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(TITLE_FOR_HEADER_IN_SECTION_FONT_SIZE)])
    //        let titleLabel = UILabel(frame: CGRectMake(0, 0, labelSize.width , labelSize.height))
    //        let headerViewForSection = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, UIScreen.screenWidth(), 22))
    //        titleLabel.text = text as? String
    //        titleLabel.font = UIFont.systemFontOfSize(TITLE_FOR_HEADER_IN_SECTION_FONT_SIZE)
    //
    //        titleLabel.center.y = 14
    //        titleLabel.frame.origin.x = 18
    //        headerViewForSection.addSubview(titleLabel)
    //
    //        headerViewForSection.backgroundColor = UIColor.redColor()
    //        return headerViewForSection
    //
    //
    //    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    
    
}

extension IBBSDetailViewController {
    // MARK: - refresh
    func refreshData(){
        
        sendRequest(page)
        //         be sure to stop refreshing while there is an error with network or something else
        let refreshInSeconds = 1.3
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
            self.page = 1
            self.gearRefreshControl.endRefreshing()
        }
        
    }
    
    // MARK: - pull up to load more
    func pullUpToLoadmore(){
        tableView.addFooterWithCallback({
            DEBUGLog("pulling up")
            self.page += 1
            DEBUGLog(self.page)
            
            self.sendRequest(self.page)
            let delayInSeconds: Double = 1.0
            let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delta)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                //                tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
            })
        })
    }
}
