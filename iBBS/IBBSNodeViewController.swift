//
//  IBBSNodeViewController.swift
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


class IBBSNodeViewController: IBBSBaseViewController, UIGestureRecognizerDelegate {
    
    var nodeJSON: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pullUpToLoadmore()
        configureTableView()
        configureView()
        configureGestureRecognizer()
        sendRequest(page)
        postNewArticleSegue = MainStoryboard.SegueIdentifiers.postNewArticleWithNodeSegue
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadDataAfterPosting), name: kShouldReloadDataAfterPosting, object: nil)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        navigationController?.hidesBarsOnSwipe = true
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.enabled = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kShouldReloadDataAfterPosting, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        //        navigationController?.setNavigationBarHidden(true , animated: true)
        //        toggleSideMenuView()
        
    }

    
    func sendRequest(page: Int) {
        if let node = nodeJSON {
            APIClient.sharedInstance.getLatestTopics(node["id"].stringValue, page: page, success: { (json) -> Void in
                if json == nil && page != 1 {
                    ASStatusBarToast.makeStatusBarToast(NO_MORE_DATA, interval: TIME_OF_TOAST_OF_NO_MORE_DATA)
                }
                
                if json.type == Type.Array {
                    if page == 1{
                        self.datasource = json.arrayValue
                        
                    }else {
                        let appendArray = json.arrayValue
                        self.datasource? += appendArray
                        self.tableView.reloadData()
                        debugPrint(self.datasource)
                    }
                    
                }
                }, failure: { (error) -> Void in
                    DEBUGLog(error)
                    ASStatusBarToast.makeStatusBarToast(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
            })
        }
    }
    
    func configureView(){
        navigationController?.navigationBarHidden = false
        
        if let node = nodeJSON {
            title = node["title"].stringValue
        }else {
            title = "iBBS"
        }
    }
    
    func configureTableView(){
        tableView.registerNib(UINib(nibName: MainStoryboard.NibIdentifiers.iBBSNodeTableViewCellName, bundle: nil ), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.iBBSNodeTableViewCell)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureGestureRecognizer(){
        let edgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(IBBSNodeViewController.toggleSideMenu(_:)))
        edgeGestureRecognizer.edges = UIRectEdge.Right
        view.addGestureRecognizer(edgeGestureRecognizer)
    }

    override func cornerActionButtonDidTap() {
        performPostNewArticleSegue(segueIdentifier: MainStoryboard.SegueIdentifiers.postNewArticleWithNodeSegue)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            //            DEBUGLog(datasource)
            
            return datasource.count
            
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.iBBSNodeTableViewCell) as? IBBSNodeTableViewCell {
            let json = datasource[indexPath.row]
            DEBUGLog("****************")
            debugPrint(json)
            DEBUGLog("****************")
            DEBUGLog("****************")
            cell.loadDataToCell(json)
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    // MARK: - table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let json = datasource[indexPath.row]
//        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.VCIdentifiers.iBBSDetailVC) as? IBBSDetailViewController {
//            destinationVC.json = json
//            navigationController?.pushViewController(destinationVC, animated: true)
//        }
        let destinationVC = IBBSDetailViewController()
        destinationVC.json = json
        navigationController?.pushViewController(destinationVC, animated: true)
            
        
    }
    
    
}


extension IBBSNodeViewController {
    // MARK: - refresh
    override func refreshData(){
        super.refreshData()
        
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
