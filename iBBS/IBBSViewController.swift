//
//  IBBSViewController.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

let postSegue = "postNewArticle"

class IBBSViewController: IBBSBaseViewController {
    
    // for double tapping tab bar
    private var tapCounter : Int = 0
    private var previousVC = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        
        automaticPullingDownToRefresh()
        configureTableView()
        configureNavigationItemTitle()
        pullUpToLoadmore()
        sendRequest(page)
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(cornerActionButtonDidTap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadDataAfterPosting), name: kShouldReloadDataAfterPosting, object: nil)
        
        let nodesController = IBBSNodesCollectionViewController()
        nodesController.getNodesIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /**
         important: if present NavigationController's property of interactivePopGestureRecognizer is enable, we must set it to disable,
         otherwise if we call UIScreenEdgePanGestureRecognizer on present ViewController it will crash.
         */
        //        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(configureNavigationItemTitle), name: kJustLoggedinNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kJustLoggedinNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func sendRequest(page: Int) {
        
        APIClient.defaultClient.getLatestTopics(page, success: { (json) -> Void in
            
            DEBUGPrint(json)
            
            if json == nil && page != 1 {
                IBBSToast.make(NO_MORE_DATA, delay: 0, interval: TIME_OF_TOAST_OF_NO_MORE_DATA)
                self.tableView.reloadData()
                return
            }
            
            if json.type == Type.Array {
                if page == 1 {
                    self.datasource = json.arrayValue
                    
                } else {
                    let appendArray = json.arrayValue
                    
                    self.datasource? += appendArray
                }
                self.tableView.reloadData()
            }
            
            }, failure: { (error) -> Void in
                DEBUGLog(error)
                IBBSToast.make(SERVER_ERROR, delay: 0, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
        })
    }
    
    
    @objc private func configureNavigationItemTitle() {
        
        navigationItem.title = "iBBS"
        
        let key = IBBSLoginKey()
        
        guard key.isValid && key.username != nil else { return }
        
        self.navigationItem.title = key.username
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
        performPostNewArticleSegue(segueIdentifier: postSegue)
    }
    
}

extension IBBSViewController {
    
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

extension IBBSViewController {
    
    // MARK: - refresh
    override func refreshData() {
        super.refreshData()
        
        sendRequest(page)
        //         be sure to stop refreshing while there is an error with network or something else
        let refreshInSeconds = 1.3
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.page = 1
            self.gearRefreshControl?.endRefreshing()
        }
        
    }
    
    
    // MARK: - pull up to load more
    func pullUpToLoadmore() {
        tableView.addFooterWithCallback({

            self.page += 1
            DEBUGLog("page: \(self.page)")
            
            self.sendRequest(self.page)
            
            executeAfterDelay(1.0, completion: {
                self.tableView.footerEndRefreshing()
            })
        })
    }
    
}


// MARK: - double tap tab bar to refresh

extension IBBSViewController: UITabBarControllerDelegate {
    
    // Handle double tapping on bar item
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        tapCounter += 1
        
        let hasTappedTwice = previousVC == viewController
        previousVC = viewController
        
        if tapCounter == 2 && hasTappedTwice {
            DEBUGLog("Tab bar did double tap")
            
            tapCounter = 0
            
            sendRequest(page)
            
            guard tableView.numberOfSections != 0 && tableView.numberOfRowsInSection(0) != 0 else { return false }
            
            let topIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.scrollToRowAtIndexPath(topIndexPath, atScrollPosition: .Top, animated: false)
            automaticContentOffset()
        }
        
        if tapCounter == 1 {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.tapCounter = 0
            })
        }
        
        return true
    }
}
