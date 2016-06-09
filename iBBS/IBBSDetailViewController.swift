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

class IBBSDetailViewController: IBBSBaseViewController, UIGestureRecognizerDelegate, IBBSCommentViewControllerDelegate {
    
    var json: JSON!
    
    private var headerView: IBBSDetailHeaderView!
    private var prototypeCell: IBBSReplyCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendRequest(page)
        pullUpToLoadmore()
        configureHeaderView()
        configureTableView()
        configureGesture()
        configureDeleteItemIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func cornerActionButtonDidTap() {
        
        let key = IBBSLoginKey()
        
        if key.isValid {
            
            guard let vc = UIStoryboard.Main.instantiateViewControllerWithIdentifier(String(IBBSCommentViewController)) as? IBBSCommentViewController else { return }
            
            let model   = IBBSTopicModel(json: json)
            vc.post_id  = model.id
            vc.delegate = self
            
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.topMostViewController?.presentViewController(nav, animated: true, completion: nil)
            
        } else {
            
            IBBSContext.login(cancelled: nil, completion: {
                self.cornerActionButtonDidTap()
            })
        }
    }
    
    private func configureDeleteItemIfNeeded() {
        
        let key = IBBSLoginKey()

        guard key.isValid && key.isAdmin else { return }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(deleteButtonDidTap))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.redColor()
    }
    
    @objc private func deleteButtonDidTap() {
        
        let key = IBBSLoginKey()
        
        guard key.isValid else { return }
        
        let alertController = UIAlertController(title: DELTE_THIS_TOPIC, message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: DELETE, style: .Destructive) { (_) in
            self.deleteTopic()
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func deleteTopic() {
        
        let key = IBBSLoginKey()
        
        guard key.isValid && key.isAdmin else { return }

        let postId = json["id"].stringValue
        
        APIClient.defaultClient.deleteTopic(key.uid, token: key.token, postId: postId, success: { (json) in
            
            let model = IBBSModel(json: json)
            
            if model.success {
                
                IBBSToast.make(model.message, delay: 0, interval: 3)
                self.navigationController?.popViewControllerAnimated(true)
                
            } else {
                IBBSToast.make(model.message, delay: 0, interval: 5)
            }
            
            }) { (error) in
                IBBSToast.make(DELETE_FAILED_TRY_AGAIN, delay: 0, interval: 6)
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: String(IBBSReplyCell), bundle: nil), forCellReuseIdentifier: String(IBBSReplyCell))
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func configureHeaderView() {
        
        let headerViewNib = NSBundle.mainBundle().loadNibNamed(String(IBBSDetailHeaderView), owner: self, options: nil)
        headerView = headerViewNib.first as! IBBSDetailHeaderView
        
        headerView.loadData(json)
        
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
    
    private func sendRequest(page: Int) {
        
        APIClient.defaultClient.getReplies(json["id"].stringValue, page: page, success: { (json) -> Void in
            
            if json == nil && page != 1 {
                IBBSToast.make(NO_MORE_DATA, interval: TIME_OF_TOAST_OF_NO_MORE_DATA)
                return
            }
            
            if json.type == Type.Array {
                if page == 1{
                    self.datasource = json.arrayValue
                    self.tableView.reloadData()
                }else {
                    let appendArray = json.arrayValue
                    self.datasource? += appendArray
                    self.tableView.reloadData()
                }
            }
            
        }) { (error) -> Void in
            DEBUGLog(error)
            IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
        }
    }
    
    // MARK: - configure gesture
    private func configureGesture() {
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
    
}


// MARK: - table view data source

extension IBBSDetailViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            return datasource.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(String(IBBSReplyCell)) as? IBBSReplyCell {
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
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        // customize title for header in section
        header.textLabel?.font = UIFont.systemFontOfSize(14)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
}


extension IBBSDetailViewController {
    
    // MARK: - refresh
    
    override func refreshData() {
        super.refreshData()
        
        sendRequest(page)
        
        // be sure to stop refreshing while there is an error with network or something else
        executeAfterDelay(1.3) {
            self.tableView.reloadData()
            self.page = 1
            self.gearRefreshControl.endRefreshing()
        }
    }
    
    
    // MARK: - pull up to load more
    
    private func pullUpToLoadmore() {
        
        tableView.addFooterWithCallback({

            self.page += 1
            DEBUGLog(self.page)
            
            self.sendRequest(self.page)
            
            executeAfterDelay(1.0, completion: {
                self.tableView.footerEndRefreshing()
            })
        })
    }
}
