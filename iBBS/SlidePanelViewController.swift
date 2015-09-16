//
//  SlidePanelViewController.swift
//  SlideMenu
//
//  Created by Augus on 4/27/15.
//  Copyright (c) 2015 Augus. All rights reserved.
//

import UIKit
import SwiftyJSON



class SlidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    struct MainStoryBoard {
        struct TableViewCellIdentifiers {
            static let slidePanelCell = "slidePanelCell"
        }
    }
    @IBOutlet weak var userProfileImage: UIImageView!{
        didSet{
            userProfileImage.layer.cornerRadius = 35.0
            userProfileImage.clipsToBounds = true
            self.configureLoginAndLogoutView(userProfileImage)
            
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var loginAlertController: UIAlertController!
    private var logoutAlertController: UIAlertController!
    private let loginFeedbackJson = "loginFeedbackJson"
    
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.grayColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
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
            if IBBSContext.sharedInstance.isLogin() {
                // do logout
                self.logoutAlertController = UIAlertController()
                IBBSContext.sharedInstance.logout(logoutAlertController, presentingVC: self)
            }else{
                // do login
                self.loginAlertController = UIAlertController()
                IBBSContext.sharedInstance.login(loginAlertController, presentingVC: self, avatar: userProfileImage)
            }
        }
        
    }

    
    // MARK: - table view delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(MainStoryBoard.TableViewCellIdentifiers.slidePanelCell)
        if cell == nil {
            cell = UITableViewCell()
            cell?.frame = CGRectZero
        }
        
        cell?.textLabel?.text = "@"
        cell?.backgroundColor = UIColor.clearColor()
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsetsZero
        cell?.separatorInset = UIEdgeInsetsZero
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("ok")
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
