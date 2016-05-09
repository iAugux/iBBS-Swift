//
//  IBBSFavoriteContainerViewController.swift
//  iBBS
//
//  Created by Augus on 5/5/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON


let postNewArticleInFavoriteVCSegueId = "favoriteControllerPresentEditingVC"

class IBBSFavoriteContainerViewController: IBBSBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        automaticPullingDownToRefresh()
        configureTableView()
        sendRequest()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /**
         important: if present NavigationController's property of interactivePopGestureRecognizer is enable, we must set it to disable,
         otherwise if we call UIScreenEdgePanGestureRecognizer on present ViewController it will crash.
         */
        //        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    private func sendRequest() {
        
        let key = IBBSLoginKey()
        
        guard key.isValid else {
            IBBSContext.loginIfNeeded(alertMessage: PLEASE_LOGIN, completion: nil)
            return
        }
        
        APIClient.defaultClient.getFavoriteTopics(key.uid, token: key.token, success: { (json) -> Void in
            
            DEBUGPrint(json)
            
            if json == nil {
                IBBSToast.make(NO_DATA, delay: 0, interval: TIME_OF_TOAST_OF_NO_MORE_DATA)
                self.tableView.reloadData()
                return
            }
                        
            if json.type == Type.Array {
                self.datasource = json.arrayValue
                self.tableView.reloadData()
            }
            
            }, failure: { (error) -> Void in
                DEBUGLog(error)
                IBBSToast.make(SERVER_ERROR, delay: 0, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
        })
    }
    
    private func configureTableView() {
        tableView.registerNib(UINib(nibName: String(IBBSTableViewCell), bundle: nil ), forCellReuseIdentifier: String(IBBSTableViewCell))
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func cornerActionButtonDidTap() {
        performPostNewArticleSegue(segueIdentifier: postNewArticleInFavoriteVCSegueId)
    }
    
}

extension IBBSFavoriteContainerViewController {
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(String(IBBSTableViewCell)) as? IBBSTableViewCell {
            let json = datasource[indexPath.row]
            cell.loadDataToCell(json)
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    // MARK: - table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let json = datasource[indexPath.row]
        
        let vc = IBBSDetailViewController()
        vc.json = json
        vc.navigationController?.navigationBar.hidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension IBBSFavoriteContainerViewController {
    
    override func automaticContentOffset() {
        gearRefreshControl.beginRefreshing()
        tableView.setContentOffset(CGPointMake(0, -125.0), animated: true)
        
        executeAfterDelay(0.5) {
            self.gearRefreshControl.endRefreshing()
        }
    }
    
    // MARK: - refresh
    override func refreshData() {
        super.refreshData()
        
        sendRequest()
        //         be sure to stop refreshing while there is an error with network or something else
        let refreshInSeconds = 1.3
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.page = 1
            self.gearRefreshControl?.endRefreshing()
        }
    }
    
}

