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
import SnapKit
import GearRefreshControl
import SwiftyJSON


class IBBSBaseViewController: UITableViewController {
    
    var gearRefreshControl: GearRefreshControl!
    var cornerActionButton: UIButton!
    var page: Int = 1

    var datasource: [JSON]!
    
    private var nodeId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gearRefreshManager()
        configureCornerActionButton()
        
        navigationController?.navigationBar.hidden = SHOULD_HIDE_NAVIGATIONBAR
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IBBSBaseViewController.updateTheme), name: kThemeDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IBBSBaseViewController.hideCornerActionButton), name: kShouldHideCornerActionButton, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IBBSBaseViewController.showCornerActionButton), name: kShouldShowCornerActionButton, object: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cornerActionButton?.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IBBSBaseViewController.showCornerActionButton), name: kShouldShowCornerActionButton, object: nil)
        
        #if DEBUG
            let appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelagate.window?.bringSubviewToFront(appDelagate.fps)
        #endif
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cornerActionButton?.hidden = true
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kShouldShowCornerActionButton, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        cornerActionButton?.backgroundColor = CUSTOM_THEME_COLOR.lighterColor(0.85) //UIColor(red:0.854, green:0.113, blue:0.223, alpha:1)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     private func configureCornerActionButton() {
        cornerActionButton = UIButton()
        cornerActionButton?.layer.cornerRadius = 20.0
        cornerActionButton?.clipsToBounds = true
        cornerActionButton?.setImage(UIImage(named: "plus_button"), forState: .Normal)
        cornerActionButton?.addTarget(self, action: #selector(IBBSBaseViewController.cornerActionButtonDidTap), forControlEvents: .TouchUpInside)
        
        guard let topView = UIApplication.topMostViewController?.view else { return }
        
        topView.addSubview(cornerActionButton)
        cornerActionButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(-16)
            make.bottom.equalTo(-70)
        }
    }
    
    func cornerActionButtonDidTap() {}
    
    internal func updateTheme() {
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]
        cornerActionButton?.backgroundColor = CUSTOM_THEME_COLOR.lighterColor(0.85)
        
        /**
           I tried to set `gearTintColor` to `gearRefreshControl`, but the color of all of gears didn't change.
           Because other gears' color is computed automatically according to main gear.
            
        I removed `gearRefreshControl`, then set it again.
        */
//        gearRefreshControl.gearTintColor = CUSTOM_THEME_COLOR.lighterColor(0.7)
        
        gearRefreshControl?.endRefreshing()
        gearRefreshControl?.removeFromSuperview()
        gearRefreshManager()
    }
        
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        gearRefreshControl?.scrollViewDidScroll(scrollView)
    }
    
    private func gearRefreshManager() {
        gearRefreshControl = GearRefreshControl(frame: view.bounds)
        gearRefreshControl.gearTintColor = CUSTOM_THEME_COLOR.lighterColor(0.7)
        gearRefreshControl.addTarget(self, action: #selector(IBBSBaseViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl = gearRefreshControl
    }
    
    
    // MARK: - Automatic pulling down to refresh
    func automaticPullingDownToRefresh() {
        
        NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: #selector(IBBSBaseViewController.automaticContentOffset), userInfo: nil, repeats: false)
        //        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "endRefresh", userInfo: nil, repeats: false)
        //        NSTimer.performSelector("endRefresh", withObject: nil, afterDelay: 0.1)
    }
    
    func automaticContentOffset() {
        gearRefreshControl.beginRefreshing()
        tableView.setContentOffset(CGPointMake(0, -125.0), animated: true)

        executeAfterDelay(0.5) {
            self.gearRefreshControl.endRefreshing()
        }
    }
    
    func hideCornerActionButton() {
        cornerActionButton?.hidden = true
    }
    
    func showCornerActionButton() {
        cornerActionButton?.hidden = false
    }

}

extension IBBSBaseViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == postNewArticleWithNodeSegue || segue.identifier == postSegue || segue.identifier == postNewArticleInFavoriteVCSegueId {
            
            guard let destinationVC = segue.destinationViewController as? UINavigationController else { return }

            let edittingVC = destinationVC.viewControllers.first as? IBBSEditingViewController
            
            edittingVC?.segueId = segue.identifier
            edittingVC?.nodeId = nodeId
            nodeId = nil
        }
    }
    
    func performPostNewArticleSegue(segueIdentifier segueID: String, nodeId: Int? = nil) {
        
        self.nodeId = nodeId
        
        let key = IBBSLoginKey()
        
        if key.isValid {
            performSegueWithIdentifier(segueID, sender: self)
            
        } else {
            IBBSContext.loginIfNeeded(alertMessage: LOGIN_TO_POST, completion: {
                self.performPostNewArticleSegue(segueIdentifier: segueID)
            })
        }
    }
    
    func refreshData() {}

    func reloadDataAfterPosting() {
        DEBUGLog("reloading")
        if page == 1 {
            performSelector(#selector(IBBSBaseViewController.refreshData))
            automaticPullingDownToRefresh()
        }
    }
    
}
