//
//  IBBSBaseViewController.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class IBBSBaseViewController: UITableViewController {
    var gearRefreshControl: GearRefreshControl!
    
    
    
//    var refreshing: Bool = false {
//        didSet {
//            if (self.refreshing) {
//                self.gearRefreshControl.beginRefreshing()
//            }
//            else {
//                self.gearRefreshControl.endRefreshing()
//            }
//        }
//    }
    
    var datasource: [JSON]! {
        didSet{
            //            print(datasource)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.automaticPullingDownToRefresh()
        self.gearRefreshManager()

        // theme
        if kShouldCustomizeTheme {
            self.view.backgroundColor = kThemeColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // MARK: - part of GearRefreshControl
   
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    private func gearRefreshManager(){
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl = gearRefreshControl
        tableView?.addSubview(refreshControl!)
    }
    

    // MARK: - Automatic pulling down to refresh
    func automaticPullingDownToRefresh(){
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "automaticContentOffset", userInfo: nil, repeats: false)
        //        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "endRefresh", userInfo: nil, repeats: false)
        //        NSTimer.performSelector("endRefresh", withObject: nil, afterDelay: 0.1)
    }
    
    func automaticContentOffset(){
        self.gearRefreshControl.beginRefreshing()
        self.tableView.setContentOffset(CGPointMake(0, -125.0), animated: true)
        
        let delayInSeconds: Double = 0.6
        let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
        
        let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delta)
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.gearRefreshControl.endRefreshing()
            
        })

    }
    
    
    func setupLoadmore(){
        self.tableView.addFooterWithCallback({
            //                for var i = 0; i < 90; i++ {
            //    //                self.numberOfRows?.addObject(0)
            //                }
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
