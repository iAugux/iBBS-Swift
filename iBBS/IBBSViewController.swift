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

class IBBSViewController: IBBSBaseViewController {
    
    @IBOutlet var postNewArticleButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticPullingDownToRefresh()
        configureTableView()
        configureNavifationItemTitle()
        pullUpToLoadmore()
        sendRequest(page)
        postNewArticleSegue = MainStoryboard.SegueIdentifiers.postSegue

        IBBSConfigureNodesInfo.sharedInstance.configureNodesInfo()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadDataAfterPosting", name: kShouldReloadDataAfterPosting, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        navigationController?.hidesBarsOnSwipe = true
        
        /**
        important: if present NavigationController's property of interactivePopGestureRecognizer is enable, we must set it to disable,
        otherwise if we call UIScreenEdgePanGestureRecognizer on present ViewController it will crash.
        */
        //        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "configureNavifationItemTitle", name: kJustLoggedinNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kJustLoggedinNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func sendRequest(page: Int) {
        
        APIClient.sharedInstance.getLatestTopics(page, success: { (json) -> Void in
            if json == nil && page != 1 {
                
                UIApplication.topMostViewController()?.view?.makeToast(message: NO_MORE_DATA, duration: TIME_OF_TOAST_OF_NO_MORE_DATA, position: HRToastPositionCenter)
            }
            if json.type == Type.Array {
                if page == 1{
                    self.datasource = json.arrayValue
                    
                }else {
                    let appendArray = json.arrayValue
                    
                    self.datasource? += appendArray
                    self.tableView.reloadData()
                }
                
            }
            }, failure: { (error) -> Void in
                DEBUGLog(error)
                self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
        })
    }
    
    
    func configureNavifationItemTitle(){
        
        navigationItem.title = "iBBS"
        IBBSContext.sharedInstance.isTokenLegal(){ (isTokenLegal) -> Void in
            if isTokenLegal {
                if let data = IBBSContext.sharedInstance.getLoginData() {
                    let username = data["username"].stringValue
                    self.navigationItem.title = username
                }
            }
        }
    }
    
    func configureTableView(){
        tableView.registerNib(UINib(nibName: MainStoryboard.NibIdentifiers.iBBSTableViewCell, bundle: nil ), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.iBBSTableViewCell)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func cornerActionButtonDidTap() {
        performPostNewArticleSegue(segueIdentifier: MainStoryboard.SegueIdentifiers.postSegue)
        
    }
    
    @IBAction func postNewArticleButtonDidTap(sender: AnyObject) {
        performPostNewArticleSegue(segueIdentifier: MainStoryboard.SegueIdentifiers.postSegue)
    }
    
    
}

extension IBBSViewController {
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            DEBUGLog(datasource.count)
            return datasource.count
            
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.iBBSTableViewCell) as? IBBSTableViewCell {
            let json = datasource[indexPath.row]
            DEBUGLog(json)
            
            cell.loadDataToCell(json)
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    // MARK: - table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let json = datasource[indexPath.row]
        //        if let vc = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.VCIdentifiers.detailVC) as? IBBSDetailViewController{
        //            vc.json = json
        //            navigationController?.pushViewController(vc, animated: true)
        //        }
        let vc = IBBSDetailViewController()
        vc.json = json
        vc.navigationController?.navigationBar.hidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == MainStoryboard.SegueIdentifiers.postSegue {
            whoCalledEditingViewController = -1
        }
    }
    
}

extension IBBSViewController {
    // MARK: - refresh
    func refreshData(){
        
        sendRequest(page)
        //         be sure to stop refreshing while there is an error with network or something else
        let refreshInSeconds = 1.3
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
            self.page = 1
            self.gearRefreshControl?.endRefreshing()
        }
        
    }
    
    
    // MARK: - pull up to load more
    func pullUpToLoadmore(){
        tableView.addFooterWithCallback({
            DEBUGLog("pulling up")
            self.page += 1
            DEBUGLog("page: \(self.page)")
            
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

