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

let postNewArticleWithNodeSegue = "postNewArticleWithNode"

class IBBSBaseViewController: UITableViewController {
    var gearRefreshControl: GearRefreshControl!
    var cornerActionButton: UIButton!
    var page: Int = 1
    var postNewArticleSegue: String!
    

    var datasource: [JSON]! {
        didSet{
            tableView.reloadData()
        }
    }
    
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
    
    func configureCornerActionButton() {
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
    
    func cornerActionButtonDidTap() {
        DEBUGLog("corner action button did tap")
        let alertCtrl = UIAlertController(title: "", message: "TODO...", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel , handler: nil)
        alertCtrl.addAction(cancelAction)
        UIApplication.topMostViewController?.presentViewController(alertCtrl, animated: true, completion: nil)
    }
    
    
    func updateTheme() {
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
        DEBUGLog("hide corner button")
        cornerActionButton?.hidden = true
    }
    
    func showCornerActionButton() {
        DEBUGLog("show corner button")
        cornerActionButton?.hidden = false
    }
    



}

extension IBBSBaseViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == postNewArticleWithNodeSegue {
            if let destinationVC = segue.destinationViewController as? UINavigationController {
                
                presentLoginViewControllerIfNotLogin(alertMessage: LOGIN_TO_POST, completion: {
                    
                    self.presentViewController(destinationVC, animated: true, completion: nil)
                })
            }
        }
    }
    
    func performPostNewArticleSegue(segueIdentifier segueID: String) {
        
        let key = IBBSLoginKey()
        
        if key.isValid {
            performSegueWithIdentifier(segueID, sender: self)
            
        } else {
            presentLoginViewControllerIfNotLogin(alertMessage: LOGIN_TO_POST, completion:{
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
    
     func presentLoginViewControllerIfNotLogin(alertMessage message: String, completion: (() -> Void)?) {
        
        let key = IBBSLoginKey()
        
        guard !key.isValid else { return }
        
        let loginAlertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default, handler: { (_) -> Void in
            let vc = IBBSEffectViewController()
            vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            self.presentViewController(vc, animated: true, completion: nil)
            
            IBBSContext.sharedInstance.login(cancelled: {
                vc.dismissViewControllerAnimated(true , completion: nil)
                }, completion: {
                    vc.dismissViewControllerAnimated(true, completion: nil)
                    
                    if let completionHandler = completion {
                        completionHandler()
                    }
            })
        })
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel , handler: nil)
        loginAlertController.addAction(cancelAction)
        loginAlertController.addAction(okAction)
        
        presentViewController(loginAlertController, animated: true, completion: nil)
    }
}
