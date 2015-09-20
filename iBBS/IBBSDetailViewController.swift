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
    struct MainStoryboard {
        struct CellIdentifiers {
            static let replyCellIdentifier = "iBBSReplyCell"
        }
        struct NibNames {
            static let cellNibName = "IBBSReplyCell"
            static let headerViewNibName = "IBBSDetailHeaderView"
        }
        static let commentViewController = "iBBSCommentViewController"
    }
    
    var json: JSON!
    var headerView: IBBSDetailHeaderView!
    var prototypeCell: IBBSReplyCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendRequest(page)
        self.pullUpToLoadmore()
        self.configureHeaderView()
        self.configureTableView()
        self.configureGesture()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Comment", style: .Plain, target: self, action: "commentAction")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func commentAction() {
        if IBBSContext.sharedInstance.isLogin() {
            let post_id = json["id"].stringValue
            if let vc = IBBSCommentViewController() ?? nil {
                vc.post_id = post_id
                self.navigationController?.pushViewController(vc , animated: true)
            }
            
        }
    }
    
    func configureTableView(){
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: MainStoryboard.NibNames.cellNibName, bundle: nil), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.replyCellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureHeaderView(){
        let headerViewNib = NSBundle.mainBundle().loadNibNamed(MainStoryboard.NibNames.headerViewNibName, owner: self, options: nil)
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
        self.tableView.tableHeaderView = headerView
        self.navigationItem.title = headerView.nodeName
        
    }
    
    func customizeNavBar(color: UIColor, titleFont: UIFont, buttonFont: UIFont) {
        
        UINavigationBar.appearance().tintColor = color
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: color, NSFontAttributeName: titleFont]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: color, NSFontAttributeName: buttonFont], forState: UIControlState.Normal)
    }
    
    func sendRequest(page: Int) {
        APIClient.sharedInstance.getReplies(self.json["id"].stringValue, page: self.page, success: { (json) -> Void in
            if json.type == Type.Array {
                if self.page == 1{
                    self.datasource = json.arrayValue
                    self.tableView.reloadData()
                }else {
                    let appendArray = json.arrayValue
                    self.datasource? += appendArray
                    self.tableView.reloadData()
                    print(self.datasource)
                }
            }
            }) { (error) -> Void in
                print(error)
        }
    }
    
    // MARK: - configure gesture
    func configureGesture(){
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        if self.navigationController?.viewControllers.count == 1 {
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
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.replyCellIdentifier) as? IBBSReplyCell {
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
            return "No reply yet"
        }
        else if datasource.count == 1 {
            return "Reply : 1"
        }
        return "Replies : \(datasource.count)"
        
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
    //        let headerViewForSection = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, kScreenWidth, 22))
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
        
        self.sendRequest(page)
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
        self.tableView.addFooterWithCallback({
            print("pulling up")
            self.page += 1
            print(self.page)
            
            self.sendRequest(self.page)
            let delayInSeconds: Double = 1.0
            let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delta)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                //                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
            })
        })
    }
}
