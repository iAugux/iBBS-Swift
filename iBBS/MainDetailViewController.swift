//
//  MainDetailViewController.swift
//  iBBS
//
//  Created by Augus on 9/3/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate{
    struct MainStoryboard {
        struct CellIdentifiers {
            static let replyCellIdentifier = "iBBSReplyCell"
        }
        struct NibNames {
            static let cellNibName = "IBBSReplyCell"
            static let headerViewNibName = "IBBSDetailHeaderView"
        }
    }
    @IBOutlet weak var tableView: UITableView!
    var json: JSON!
    var headerView: IBBSDetailHeaderView!
    var prototypeCell: IBBSReplyCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: MainStoryboard.NibNames.cellNibName, bundle: nil), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.replyCellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        self.setupHeaderView()
        self.sendRequest()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //        headerView.headerTitleLabel.preferredMaxLayoutWidth = headerView.headerTitleLabel.bounds.size.width
    //        headerView.usernameLabel.preferredMaxLayoutWidth = headerView.usernameLabel.bounds.size.width
    //        headerView.timeLabel.preferredMaxLayoutWidth = headerView.timeLabel.bounds.size.width
    //        headerView.content.preferredMaxLayoutWidth = headerView.content.bounds.size.width
    //        headerView.setFrameHeight(CGRectGetMaxY(headerView.content.frame) + 20)
    //    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        headerView.setFrameHeight(CGRectGetMaxY(headerView.content.frame) + 20)
        self.tableView.tableHeaderView = headerView
    }
    
    func setupHeaderView(){
        let headerViewNib = NSBundle.mainBundle().loadNibNamed(MainStoryboard.NibNames.headerViewNibName, owner: self, options: nil)
        headerView = headerViewNib.first as! IBBSDetailHeaderView
        
        headerView?.avatarImageView.layer.cornerRadius = 14.0
        headerView?.avatarImageView.clipsToBounds = true
        headerView?.avatarImageView.layer.borderWidth = 1.0
        headerView?.avatarImageView.layer.borderColor = UIColor.blackColor().CGColor
        let url = "https:" + json["member"]["avatar_large"].stringValue
        headerView?.avatarImageView.sd_setImageWithURL(NSURL(string: url))
        
        headerView?.headerTitleLabel?.text = json["title"].stringValue
        headerView?.usernameLabel?.text = json["member"]["username"].stringValue
        headerView?.timeLabel?.text = ""
        headerView?.content?.text = json["content"].stringValue
        //        headerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        headerView?.setFrameHeight(kScreenHeight)
        self.tableView.tableHeaderView = headerView
        
    }
    
    
    func sendRequest() {
        //        self.refreshing = true
        APIClient.SharedAPIClient.getReplies(self.json["id"].stringValue, success: { (json) -> Void in
            //            self.refreshing = false
            if json.type == Type.Array {
                self.datasource = json.arrayValue
                self.tableView.reloadData()
            }
            }) { (error) -> Void in
                //                self.refreshing = false
        }
    }
    
    // MARK: - table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            return datasource.count
        }
        return 0
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.replyCellIdentifier) as! IBBSReplyCell
//        let cell = prototypeCell as! IBBSReplyCell
        let json = datasource[indexPath.row]
        cell.loadDataToCell(json)
//        cell.setFrameHeight(CGRectGetMaxX(cell.replyContent.frame))
        return cell
    }
    
    func titleForHeaderInSection() -> NSString? {
        if datasource == nil || datasource.count == 0 {
            return "No reply yet"
        }
        else if datasource.count == 1 {
            return "Reply"
        }
        return "Replies"
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text = titleForHeaderInSection()
        let labelSize = text!.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(TITLE_FOR_HEADER_IN_SECTION_FONT_SIZE)])
        let titleLabel = UILabel(frame: CGRectMake(0, 0, labelSize.width , labelSize.height))
        let headerViewForSection = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, kScreenWidth, 22))
        titleLabel.text = text as? String
        titleLabel.font = UIFont.systemFontOfSize(TITLE_FOR_HEADER_IN_SECTION_FONT_SIZE)

        titleLabel.center.y = 14
        titleLabel.frame.origin.x = 18
        headerViewForSection.addSubview(titleLabel)
        
//        headerViewForSection.tintColor = UIColor.redColor()
        return headerViewForSection
        
        
    }
    
    
    
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
////        if prototypeCell == nil {
//          let   prototypeCell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.replyCellIdentifier) as! IBBSReplyCell
////        }
//        let json = datasource[indexPath.row]
//        prototypeCell.loadDataToCell(json)
//        let contentStr = prototypeCell.replyContent.text as NSString?
//        let replyLabelSize = contentStr?.ausCalculateSize(CGSizeMake(prototypeCell.replyContent.frame.size.width, prototypeCell.frame.size.height), font: prototypeCell.replyContent.font)
//        prototypeCell.setNeedsLayout()
//        prototypeCell.layoutIfNeeded()
//        
//        let height = replyLabelSize!.height + 32
//        print(height)
//        return height
//    }
//    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 90
//    }

}
