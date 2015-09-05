//
//  MainViewController.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    struct MainStoryboard {
        struct CellIdentifiers {
            static let iBBSTableViewCell = "iBBSTableViewCell"
        }
        struct NibNames {
            static let iBBSTableViewCellNibName = "IBBSTableViewCell"
        }
        struct VCIdentifiers {
            static let mainDetailVC = "mainDetailViewController"
        }
    }
    
    var refreshControl: UIRefreshControl!
    var gearRefreshControl: GearRefreshControl!
    var refreshInSeconds: Double!
    
    
    var nodeJSON: JSON?  // json of node
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.automaticPullingDownToRefresh()
        self.sendRequest()

        tableView?.registerNib(UINib(nibName: MainStoryboard.NibNames.iBBSTableViewCellNibName, bundle: nil), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.iBBSTableViewCell)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        self.gearRefreshManager()

    }
    
    func sendRequest() {
        if let node = self.nodeJSON {
//            self.refreshing = true
            APIClient.SharedAPIClient.getLatestTopics(node["id"].stringValue, success: { (json) -> Void in
//                self.refreshing = false
                if json.type == Type.Array {
                    self.datasource = json.arrayValue
                }
                }, failure: { (error) -> Void in
//                    self.refreshing = false
            })
        } else {
//            self.refreshing = true
            APIClient.SharedAPIClient.getLatestTopics({ (json) -> Void in
//                self.refreshing = false
                if json.type == Type.Array {
                    self.datasource = json.arrayValue
                }
                }, failure: { (error) -> Void in
//                    self.refreshing = false
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
    }

    func setupView(){
        self.navigationController?.navigationBarHidden = false
//        self.navigationController?.hidesBarsOnSwipe = true
        
        if let node = self.nodeJSON {
            self.title = node["title"].stringValue
        }else {
            self.title = "iBBS"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            return datasource.count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.iBBSTableViewCell) as! IBBSTableViewCell
        
        let json = self.datasource[indexPath.row]
        cell.topicLabel?.text = json["title"].stringValue
        let avatarURL = "https:" + json["member"]["avatar_large"].stringValue
        cell.userProfireImage?.sd_setImageWithURL(NSURL(string: avatarURL))
        
        return cell
    }
    
   
    // MARK: - table view delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let json = self.datasource[indexPath.row]
        let vc = storyboard!.instantiateViewControllerWithIdentifier(MainStoryboard.VCIdentifiers.mainDetailVC) as! MainDetailViewController
        vc.json = json
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - part of GearRefreshControl
    func refresh(){
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            //            self.loadStatuses()
            self.tableView.reloadData()
            self.gearRefreshControl.endRefreshing()
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    func gearRefreshManager(){
        refreshInSeconds = 1.3
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl = UIRefreshControl()
        refreshControl = gearRefreshControl
        tableView?.addSubview(refreshControl)
    }
    
    // MARK: - Automatic pulling down to refresh
    func automaticPullingDownToRefresh(){
        
        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "automaticContentOffset", userInfo: nil, repeats: false)
        //        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "endRefresh", userInfo: nil, repeats: false)
        //        NSTimer.performSelector("endRefresh", withObject: nil, afterDelay: 0.1)
    }
    
    func automaticContentOffset(){
        self.gearRefreshControl.beginRefreshing()
        self.refresh()
        self.tableView.setContentOffset(CGPointMake(0, -125.0), animated: true)
        
    }
}
