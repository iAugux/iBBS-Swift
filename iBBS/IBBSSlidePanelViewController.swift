//
//  SlidePanelViewController.swift
//  SlideMenu
//
//  Created by Augus on 4/27/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright (c) 2015 Augus. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ToggleLeftPanelDelegate{
    func toggleLeftPanel()
    func removeFrontBlurView()
}

class SlidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userProfileImage: UIImageView!{
        didSet{
            userProfileImage.layer.cornerRadius = 35.0
            userProfileImage.clipsToBounds = true
            userProfileImage.layer.borderColor = UIColor.lightGrayColor().CGColor
            userProfileImage.layer.borderWidth = 0.3
            self.configureLoginAndLogoutView(userProfileImage)
            
        }
    }
    var delegate: ToggleLeftPanelDelegate!
    private let cellTitleArray = ["Notification", "Favorite", "Profile", "Setting"]
    private var blurView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg_image_1")!)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = self.view.bounds
        self.view.insertSubview(blurView, atIndex: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.scrollEnabled = false
        IBBSContext.sharedInstance.configureCurrentUserAvatar(self.userProfileImage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureLoginAndLogoutView(sender: UIImageView){
        let longTapGesture = UILongPressGestureRecognizer(target: self , action: "loginOrLogout:")
        sender.addGestureRecognizer(longTapGesture)
        sender.userInteractionEnabled = true
    }
    
    func loginOrLogout(gesture: UIGestureRecognizer){
        if gesture.state == .Began {
            IBBSContext.sharedInstance.isLogin(){ (isLogin) -> Void in
                if isLogin {
                    // do logout
                    IBBSContext.sharedInstance.logout(completion: {
                        self.userProfileImage.image = UIImage(named: "login")
                    })
                }else{
                    // login or register
                    
                    self.alertToChooseLoginOrRegister()
                }
            }
        }
        
    }
    
    func alertToChooseLoginOrRegister(){
        let alertCtrl = UIAlertController(title: "", message: REGISTER_OR_LOGIN, preferredStyle: .Alert)
        let loginAction = UIAlertAction(title: BUTTON_LOGIN, style: .Default) { (_) -> Void in
            // login
            
            self.delegate?.toggleLeftPanel()
            IBBSContext.sharedInstance.login(cancelled: {
                self.delegate?.removeFrontBlurView()
                }, completion: {
                IBBSContext.sharedInstance.configureCurrentUserAvatar(self.userProfileImage)
                self.delegate?.removeFrontBlurView()
                self.tableView.reloadData()
            })
            
        }
        let registerAction = UIAlertAction(title: BUTTON_REGISTER, style: .Default) { (_) -> Void in
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("iBBSRegisterViewController") as! IBBSRegisterViewController
            
            //            UIView.animateWithDuration(0.75, animations: { () -> Void in
            //                UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            //                self.navigationController?.pushViewController(vc, animated: true)
            //                UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: self.navigationController!.view, cache: false)
            //            })
            self.navigationController?.pushViewController(vc, animated: true)
            self.delegate?.toggleLeftPanel()
            
            // after pushing view controller, remove the blur view
            let delayInSeconds: Double = 1
            let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
            let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                // do something
                self.delegate?.removeFrontBlurView()
            })
            
            
        }
        alertCtrl.addAction(loginAction)
        alertCtrl.addAction(registerAction)
        self.presentViewController(alertCtrl, animated: true, completion: nil)
    }
    
    
    // MARK: - table view delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clearColor()
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.text = cellTitleArray[indexPath.row]
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 50))
        headerView.backgroundColor = UIColor.grayColor()
        headerView.alpha = 0.3
        
        return headerView
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("ok")
    }
    
}

