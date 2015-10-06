//
//  IBBSBaseViewController.swift
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
import GearRefreshControl
import SwiftyJSON



class IBBSBaseViewController: UITableViewController, ContainerViewControllerDelegate {
    var gearRefreshControl: GearRefreshControl!
    var cornerActionButton: UIButton!
    var page: Int = 1
    

    var datasource: [JSON]! {
        didSet{
            //            print(datasource)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gearRefreshManager()
        self.configureCornerActionButton()
        self.navigationController?.navigationBar.hidden = SHOULD_HIDE_NAVIGATIONBAR
        
        
        // TODO: - hide corner action button when slide left vc
        let containerVC = ContainerViewController()
        containerVC.delegate = self
        print("***********************************************************")
        print(containerVC.delegate)
        print("***********************************************************")

        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = CUSTOM_THEME_COLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]
        
        cornerActionButton.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cornerActionButton.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCornerActionButton(){
        cornerActionButton = UIButton(frame: CGRectMake(UIScreen.screenWidth() - 66, UIScreen.screenHeight() - 110, 40, 40))
        cornerActionButton.layer.cornerRadius = 20.0
        cornerActionButton.clipsToBounds = true
        cornerActionButton.backgroundColor = CUSTOM_THEME_COLOR //UIColor(red:0.854, green:0.113, blue:0.223, alpha:1)
        cornerActionButton.setImage(UIImage(named: "plus_button"), forState: .Normal)
        cornerActionButton.addTarget(self, action: "cornerActionButtonDidTap", forControlEvents: .TouchUpInside)
        UIApplication.topMostViewController()?.view.addSubview(cornerActionButton)
    }
    
    
    // MARK: - part of GearRefreshControl
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    private func gearRefreshManager(){
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.gearTintColor = CUSTOM_THEME_COLOR //UIColor.yellowColor()
        
        gearRefreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl = gearRefreshControl
        
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
    
    // ContainerViewControllerDelegate
    func hideCornerActionButton() {
        print("hide corner button")
        self.cornerActionButton.hidden = true
    }
    
    func showCornerActionButton() {
        print("show corner button")
        self.cornerActionButton.hidden = false
    }
}
