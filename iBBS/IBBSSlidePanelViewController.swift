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
import SnapKit
import SwiftyJSON


class SlidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private lazy var removeFrontBlurView = {
        return appDelegate.containerViewController?.removeFrontBlurView()
    }
    
    private lazy var toggleLeftPanel = {
        return appDelegate.containerViewController?.toggleLeftPanel()
    }
    
    @IBOutlet weak var userProfileImage: IBBSAvatarImageView! {
        didSet{
            userProfileImage.antiOffScreenRendering = false
            
            userProfileImage.backgroundColor = CUSTOM_THEME_COLOR.darkerColor(0.75)
            userProfileImage.image = AVATAR_PLACEHOLDER_IMAGE
            configureLoginAndLogoutView(userProfileImage)
            
            let key = IBBSLoginKey()
            
            guard let id = key.uid, let name = key.username else { return }
            userProfileImage.user = User(id: id, name: name)
            
            guard let url = key.avatar else { return }
            userProfileImage.kf_setImageWithURL(url, placeholderImage: nil)
        }
    }
    
    @IBOutlet weak var loginStatusIndicator: UIView! {
        didSet {
            loginStatusIndicator.layer.cornerRadius = loginStatusIndicator.frame.width / 2
            changeLoginStatusIndicatorColor()
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var themePickerBar: FrostedSidebar!
    
    private let cellTitleArray = ["", "Settings"]//["", "Favorites", "Settings"]
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor(patternImage: BACKGROUNDER_IMAGE!)
        
        // blur view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.alpha = BLUR_VIEW_ALPHA_OF_BG_IMAGE
        view.insertSubview(blurView, atIndex: 0)
        blurView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.scrollEnabled = false
        IBBSContext.configureCurrentUserAvatar(userProfileImage)
        
        NSNotificationCenter.defaultCenter().postNotificationName(kShouldHideCornerActionButton, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName(kShouldHideCornerActionButton, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if themePickerBar != nil {
            showThemePickerView()
        }
    }
    
    private func changeLoginStatusIndicatorColor() {
        let key = IBBSLoginKey()
        let color = key.isValid ? UIColor.greenColor() : UIColor.redColor()
        
        loginStatusIndicator.backgroundColor = color
    }
    
    // MARK: - configure login and register
    private func configureLoginAndLogoutView(sender: UIImageView) {
        let longTapGesture = UILongPressGestureRecognizer(target: self , action: #selector(loginOrLogout(_:)))
        sender.addGestureRecognizer(longTapGesture)
        sender.userInteractionEnabled = true
    }
    
    @objc private func loginOrLogout(gesture: UIGestureRecognizer) {
        
        guard gesture.state == .Began else { return }
        
        let key = IBBSLoginKey()
        
        guard !key.isValid else {
            // logout
            IBBSContext.logout(completion: {
                self.userProfileImage.image = AVATAR_PLACEHOLDER_IMAGE
                self.changeLoginStatusIndicatorColor()
            })
            return
        }

        // login or register
        
        if key.token == nil {
            alertToChooseLoginOrRegister()
            
        } else {
            // token invalid, login again
            
            let alertVC = UIAlertController(title: TOKEN_LOST_EFFECTIVENESS, message: PLEASE_LOGIN_AGAIN, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: BUTTON_OK, style: .Default, handler: { (_) -> Void in
                
                self.toggleLeftPanel()
                
                IBBSContext.login(cancelled: {
                    
                    self.removeFrontBlurView()

                    }, completion: {
                        IBBSContext.configureCurrentUserAvatar(self.userProfileImage)

                        self.removeFrontBlurView()
                        
                        // NSNotificationCenter.defaultCenter().postNotificationName(kShouldReloadDataAfterPosting, object: nil)
                })
                
            })
            
            let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
    private func alertToChooseLoginOrRegister() {
        
        let alertCtrl = UIAlertController(title: "", message: REGISTER_OR_LOGIN, preferredStyle: .Alert)
        
        let loginAction = UIAlertAction(title: BUTTON_LOGIN, style: .Default) { (_) -> Void in

            appDelegate.containerViewController?.toggleLeftPanel()
            
            IBBSContext.login(cancelled: {
                appDelegate.containerViewController?.removeFrontBlurView()
                
                }, completion: {
                IBBSContext.configureCurrentUserAvatar(self.userProfileImage)
                    
                self.removeFrontBlurView()

                NSNotificationCenter.defaultCenter().postNotificationName(kJustLoggedinNotification, object: nil)
            })
        }
        
        let registerAction = UIAlertAction(title: BUTTON_REGISTER, style: .Default) { (_) -> Void in
            
            guard let vc = UIStoryboard.User.instantiateViewControllerWithIdentifier(String(IBBSRegisterViewController)) as? IBBSRegisterViewController else { return }
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            self.toggleLeftPanel()
            
            // after pushing view controller, remove the blur view
            executeAfterDelay(1, completion: {
                self.removeFrontBlurView()
            })
        }
        
        alertCtrl.addAction(loginAction)
        alertCtrl.addAction(registerAction)
        presentViewController(alertCtrl, animated: true, completion: nil)
    }
    
    
    // MARK: - configure theme
    
    @objc private func showThemePickerView() {
        
        let imageArray = [UIImage](count: themeColorArray.count, repeatedValue: UIImage(named: "clear_color_image")!)
        
        themePickerBar = FrostedSidebar(itemImages: imageArray, colors: themeColorArray, selectedItemIndices: NSIndexSet(index: 0))
        themePickerBar.width = kExpandedOffSet
        themePickerBar.borderWidth = 10.0
        themePickerBar.itemSize = CGSizeMake(60, 60)
        themePickerBar.isSingleSelect = true
        themePickerBar.actionForIndex = [
            0: {self.changeThemeAndDismissSelf(.DefaultTheme)},
            1: {self.changeThemeAndDismissSelf(.RedTheme)},
            2: {self.changeThemeAndDismissSelf(.GreenTheme)},
            3: {self.changeThemeAndDismissSelf(.YellowTheme)},
            4: {self.changeThemeAndDismissSelf(.PurpleTheme)},
            5: {self.changeThemeAndDismissSelf(.PinkTheme)},
            6: {self.changeThemeAndDismissSelf(.BlackTheme)}]
        
        themePickerBar.showInViewController(self, animated: true)
    }
    
    private func changeThemeAndDismissSelf(theme: IBBSThemes) {
        
        theme.setTheme()

        // save theme
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(theme.hashValue, forKey: kCurrentTheme)
        userDefaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(kThemeDidChangeNotification, object: nil)
        
        executeAfterDelay(0.8) {
            self.toggleLeftPanel()
        }
        
        executeAfterDelay(1.2) {
            self.removeFrontBlurView()
            NSNotificationCenter.defaultCenter().postNotificationName(kShouldShowCornerActionButton, object: nil)
        }
    }
    
}


// MARK: - table view data source

extension SlidePanelViewController {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitleArray.count
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
        
        let headerView = UIView(frame: CGRectMake(0, 0, kExpandedOffSet, 27))
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(showThemePickerView))
        recognizer.numberOfTapsRequired = 1

        let titleLabel = UILabel()
        titleLabel.text = BUTTON_CHANGE_THEME
        titleLabel.font = UIFont.systemFontOfSize(15)
        titleLabel.sizeToFit()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = CUSTOM_THEME_COLOR.darkerColor(0.7)
        titleLabel.center = headerView.center
        
        headerView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
        headerView.addGestureRecognizer(recognizer)
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 20
        default: return 70
        }
    }
}


// MARK: - table view delegate

extension SlidePanelViewController {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var destinationVC: UIViewController!
        
        switch indexPath.row {
//        case 1:
//            
//            appDelegate.containerViewController?.toggleLeftPanel()
//            appDelegate.containerViewController?.removeFrontBlurView()
//            
//            destinationVC = UIStoryboard.SlidePanel.instantiateViewControllerWithIdentifier(String(IBBSFavoriteViewController))
//            let nav = UINavigationController(rootViewController: destinationVC)
//            presentViewController(nav, animated: true, completion: nil)
//            
        case 1:
            destinationVC = UIStoryboard.SlidePanel.instantiateViewControllerWithIdentifier(String(IBBSSettingViewController))
            navigationController?.pushViewController(destinationVC, animated: true)
            
        default:
            return
        }
        
        destinationVC?.title = cellTitleArray[indexPath.row]
    }
}

