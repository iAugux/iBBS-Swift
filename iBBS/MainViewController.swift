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

    static let sharedInstance = MainViewController()
    
    @IBOutlet var tableView: UITableView!{
        didSet{
            tableView.reloadData()
        }
    }
    
    var refreshControl: UIRefreshControl!
    var gearRefreshControl: GearRefreshControl!
    var refreshInSeconds: Double!
    var nodeJSON: JSON?
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.automaticPullingDownToRefresh()
        self.sendRequest()
        self.configureTableView()
        self.configureGestureRecognizer()
        self.gearRefreshManager()
        self.setupLoadmore()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.configureTableView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Your Menu View Controller vew must know the following data for the proper animatio
//        let destinationVC = segue.destinationViewController as! GuillotineMenuViewController
//        destinationVC.hostNavigationBarHeight = self.navigationController!.navigationBar.frame.size.height
//        destinationVC.hostTitleText = self.navigationItem.title
//        destinationVC.view.backgroundColor = self.navigationController!.navigationBar.barTintColor
////        destinationVC.setMenuButtonWithImage(barButton.imageView!.image!)
//        destinationVC.setMenuButtonWithImage(UIImage(named: "refresh")!)
    }
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
//        self.navigationController?.setNavigationBarHidden(true , animated: true)
//        self.toggleSideMenuView()
        self.showSideMenuView()
        
    }
    
    
    func sendRequest() {
        if let node = self.nodeJSON {
            APIClient.sharedInstance.getLatestTopics(node["id"].stringValue, success: { (json) -> Void in
                if json.type == Type.Array {
                    self.datasource = json.arrayValue
//                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
//                    print(self.datasource)
                }
                }, failure: { (error) -> Void in
            })
        } else {
            APIClient.sharedInstance.getLatestTopics({ (json) -> Void in
                if json.type == Type.Array {
                    self.datasource = json.arrayValue
//                    self.tableView?.reloadData()
                    self.refreshControl?.endRefreshing()
                }
                }, failure: { (error) -> Void in
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
        
        /**
        important: if present NavigationController's property of interactivePopGestureRecognizer is enable, we must set it to disable,
        otherwise if we call UIScreenEdgePanGestureRecognizer on present ViewController it will crash.
        */
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
//        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    func configureView(){
        self.navigationController?.navigationBarHidden = false
//        self.navigationController?.hidesBarsOnSwipe = true
        
        if let node = self.nodeJSON {
            self.title = node["title"].stringValue
        }else {
            self.title = "iBBS"
        }
    }
   
    func configureTableView(){
        tableView?.registerNib(UINib(nibName: MainStoryboard.NibNames.iBBSTableViewCellNibName, bundle: nil), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.iBBSTableViewCell)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureGestureRecognizer(){
        let edgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "toggleSideMenu:")
        edgeGestureRecognizer.edges = UIRectEdge.Right
        self.view.addGestureRecognizer(edgeGestureRecognizer)
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
        cell.loadDataToCell(json)
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
        self.sendRequest()
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
//            self.tableView.reloadData()
            self.gearRefreshControl.endRefreshing()
        }
    
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    func gearRefreshManager(){
        refreshInSeconds = 1.1
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
    
    
    func setupLoadmore(){
        self.tableView.addFooterWithCallback({
            for var i = 0; i < 90; i++ {
//                self.numberOfRows?.addObject(0)
            }
            //                        let delayInSeconds: Double = 0.3
            //                        let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
            //                        let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delta)
            //                        dispatch_after(popTime, dispatch_get_main_queue(), {
            //                            self.tableView.reloadData()
            //                            self.tableView.footerEndRefreshing()
            //            //                self.tableView.setFooterHidden(true)
            //                        })
            self.tableView.reloadData()
            self.tableView.footerEndRefreshing()
        })
    }
}
