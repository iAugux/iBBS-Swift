//
//  IBBSUserViewController.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON


class IBBSUserViewController: UIViewController {
    
    var user: User! {
        didSet {
            headerViewbackgroundColorKey += user.name
        }
    }
    
    private var datasource:[JSON]!
    private var page: Int = 1

    private var textField996IsEmpty = true
    private var textField997IsEmpty = true
    private var textField998IsEmpty = true
    private var textField999IsEmpty = true
    
    private var blurView: UIVisualEffectView!
    private var changePasswordAction: UIAlertAction!
    private var changeUsernameAction: UIAlertAction!
    
    private var headerViewBackgroundColor: UIColor {
        get {
            return NSUserDefaults.standardUserDefaults().colorForKey(headerViewbackgroundColorKey) ?? headerViewDefaultColor
        }
        set {
            headerView.backgroundColor = newValue
            NSUserDefaults.standardUserDefaults().setColor(newValue, forKey: headerViewbackgroundColorKey)
        }
    }
    
    private var headerViewbackgroundColorKey = "headerViewbackgroundColorKey"
    
    private let segueIdentifier = "GoToChatViewController"
    private let headerViewDefaultColor = UIColor.purpleColor()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = headerViewBackgroundColor
        }
    }
    
    @IBOutlet weak var userImageView: IBBSAvatarImageView! {
        didSet {
            userImageView.antiOffScreenRendering = false
            userImageView.layer.cornerRadius = userImageView.frame.width / 2
            userImageView.userInteractionEnabled = false
            
            guard let url = IBBSLoginKey().avatar else { return }
            userImageView.kf_setImageWithURL(url, placeholderImage: nil)
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.text = user?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(dismissViewController)
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(goToChatViewController)
        
        configureTableView()
        configureViewsIfSelf()
        
        sendRequest(page)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func sendRequest(page: Int) {
        
        guard let uid = user?.id else { return }
                
        APIClient.defaultClient.getUserTopics(uid, page: page, suceess: { (json) -> Void in
            
            DEBUGPrint(json)
            
            if json == nil && page != 1 {
                IBBSToast.make(NO_MORE_DATA, delay: 0, interval: TIME_OF_TOAST_OF_NO_MORE_DATA)
            }
            
            if json.type == Type.Array {
                if page == 1 {
                    self.datasource = json.arrayValue
                    
                } else {
                    let appendArray = json.arrayValue
                    
                    self.datasource? += appendArray
                }
                self.tableView.reloadData()
            }
            
            }, failure: { (error) -> Void in
                DEBUGLog(error)
                IBBSToast.make(SERVER_ERROR, delay: 0, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == segueIdentifier {
            guard let vc = segue.destinationViewController as? IBBSChatViewController else { return }
            vc.receiver = user
        }
        else if segue.identifier == "PopColorPickerController" {
            guard let vc = segue.destinationViewController as? IBBSColorPickerViewController else { return }
            vc.delegate = self
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.sourceView = view
            vc.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSizeZero)
            vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            vc.popoverPresentationController?.backgroundColor = UIColor.clearColor()
            vc.preferredContentSize = CGSizeMake(200, 350)
        }
    }
    
    @objc private func goToChatViewController() {
        performSegueWithIdentifier(segueIdentifier, sender: nil)
    }
    
    private func configureViewsIfSelf() {
        
        guard let id = user?.id  else { return }
        guard let uid = IBBSLoginKey().uid else { return }
        
        guard id == uid else { return }
        
        // change to setting action
        navigationItem.rightBarButtonItem?.image  = UIImage(named: "settings")
        navigationItem.rightBarButtonItem?.action = #selector(showActionSheet)
    }
    
    @objc func showActionSheet() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let passwdAction = UIAlertAction(title: CHANGE_PASSWORD, style: .Default) { (_) in
            self.changePassword()
        }
        
        let usernameAction = UIAlertAction(title: CHANGE_USERNAME, style: .Default) { (_) in
            self.changeUsername()
        }
        
        let avatarAction = UIAlertAction(title: CHANGE_AVATAR, style: .Default) { (_) in
            self.changeAvatar()
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
        
        
        alertController.addAction(passwdAction)
        alertController.addAction(usernameAction)
        alertController.addAction(avatarAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


// MARK: -

extension IBBSUserViewController {
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        guard let topVC = UIApplication.topMostViewController as? IBBSColorPickerViewController else { return }
        topVC.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSizeZero)
    }
}


// MARK: - 

extension IBBSUserViewController: ColorPickerViewControllerDelegate {
    
    func colorDidChange(color: UIColor) {
        headerViewBackgroundColor = color
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension IBBSUserViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: - for iPhone 6(s) Plus
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
    
    override func overrideTraitCollectionForChildViewController(childViewController: UIViewController) -> UITraitCollection? {
        // disable default UITraitCollection, fix size of popover view on iPhone 6(s) Plus.
        return nil
    }
}


// MARK: - 

extension IBBSUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: String(IBBSUserTopicTableViewCell), bundle: nil), forCellReuseIdentifier: String(IBBSUserTopicTableViewCell))
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    // MARK: - Table View Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(String(IBBSUserTopicTableViewCell), forIndexPath: indexPath) as? IBBSUserTopicTableViewCell else { return UITableViewCell() }
        
        let json = datasource[indexPath.row]
        cell.loadDataToCell(json)
        
        return cell
    }
    
    
    // MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let json = datasource[indexPath.row]
        
        let vc = IBBSDetailViewController()
        vc.json = json
        vc.navigationController?.navigationBar.hidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - change password

extension IBBSUserViewController {
    
    private func changePassword() {

        let key = IBBSLoginKey()
        
        var oldTF, newTF, confirmTF, usernameTF: UITextField!
        
        var username = key.username
        
        textField996IsEmpty = username == nil
        
        let msg = CHECK_DIGITS_OF_PASSWORD + "\n" + CHECK_DIGITS_OF_USERNAME
        
        let alertVC = UIAlertController(title: CHANGE_PASSWORD, message: msg, preferredStyle: .Alert)
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.tag = 996
            textField.addTarget(self, action: #selector(IBBSUserViewController.changePasswdTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = HOLDER_USERNAME
            textField.text = username
            textField.enablesReturnKeyAutomatically = true
            usernameTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.tag = 997
            textField.addTarget(self, action: #selector(IBBSUserViewController.changePasswdTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = OLD_PASSWORD
            textField.secureTextEntry = true
            textField.enablesReturnKeyAutomatically = true
            oldTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.tag = 998
            textField.addTarget(self, action: #selector(IBBSUserViewController.changePasswdTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = NEW_PASSWORD
            textField.secureTextEntry = true
            textField.enablesReturnKeyAutomatically = true
            newTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) in
            textField.tag = 999
            textField.addTarget(self, action: #selector(IBBSUserViewController.changePasswdTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = CONFIRM_PASSWORD
            textField.secureTextEntry = true
            textField.enablesReturnKeyAutomatically = true
            confirmTF = textField
        }
        
        self.changePasswordAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (action: UIAlertAction) -> Void in
            
            self.removeBlurView()
            self.setAllTextFieldToEmptyStatus()
            
            guard let old = oldTF.text, let new = newTF.text, let confirm = confirmTF.text else { return }
            
            guard !(old.isEmpty || new.isEmpty || confirm.isEmpty) else { return }
            
            guard new == confirm else {
                IBBSToast.make(PASSWD_MUST_BE_THE_SAME, delay: 0, interval: 3)
                return
            }
            
            guard old != new else {
                IBBSToast.make(PLEASE_SET_NEW_PASSWORD, delay: 0, interval: 3)
                return
            }
            
            let oldMD5 = old.MD5()
            let newMD5 = new.MD5()
            
            // ready to change password
            
            username = usernameTF.text
            
            APIClient.defaultClient.changePassword(username, oldPassword: oldMD5, newPassword: newMD5, success: { (json) in
                
                let model = IBBSModel(json: json)
                
                if model.success {
                    self.alertToLogin(username, password: newMD5, title: model.message, message: LOGIN_NOW)
                } else {
                    IBBSToast.make(model.message, delay: 0, interval: 3)
                }
                
                }, failure: { (error) in
                    DEBUGLog(error)
                    IBBSToast.make(ERROR_MESSAGE, delay: 0, interval: 3)
            })
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel) { (_) -> Void in
            
            self.removeBlurView()
            
            alertVC.dismissViewControllerAnimated(true , completion: {
                self.setAllTextFieldToEmptyStatus()
            })
        }
        
        changePasswordAction.enabled = false
        
        alertVC.addAction(changePasswordAction)
        alertVC.addAction(cancelAction)
        
        self.addBlurView()

        UIApplication.topMostViewController?.presentViewController(alertVC, animated: true, completion: {
            
            guard let textFields = alertVC.textFields where textFields.count > 1 else { return }
            
            let index = username == nil ? 0 : 1
            textFields[index].becomeFirstResponder()
        })
    }
    
    private func alertToLogin(username: AnyObject, password: AnyObject, title: String?, message: String?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (_) in
            self.login(username, password: password)
            
            self.removeBlurView()
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: { _ in
            self.removeBlurView()
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        addBlurView()
        
        UIApplication.topMostViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func login(username: AnyObject, password: AnyObject) {
        
        APIClient.defaultClient.userLogin(username, passwd: password, success: { (json) -> Void in
            
            let model = IBBSModel(json: json)
            
            // something wrong , alert!!
            if !model.success {
                IBBSToast.make(model.message, delay: 0, interval: 2)
            } else {
                IBBSToast.make(model.message, delay: 0, interval: 1.5)
                
                // success , keep token and other info
                IBBSLoginKey.saveTokenJson(json.object)
            }
            
        }) { (error ) -> Void in
            DEBUGLog(error)
            IBBSToast.make(ERROR_MESSAGE, delay: 0, interval: 2)
        }
    }
   
    private func setAllTextFieldToEmptyStatus() {
        textField996IsEmpty = true
        textField997IsEmpty = true
        textField998IsEmpty = true
        textField999IsEmpty = true
    }
    
    @objc private func changePasswdTextFieldDidChange(textField: UITextField) {
        
        let isEmpty = textField.text?.isEmpty ?? true
        
        let lengthValid = textField.text?.utf8.count > 5
        
        switch textField.tag {
        case 996: textField996IsEmpty = isEmpty || !(textField.text?.utf8.count > 4)
        case 997: textField997IsEmpty = isEmpty || !lengthValid
        case 998: textField998IsEmpty = isEmpty || !lengthValid
        case 999: textField999IsEmpty = isEmpty || !lengthValid
        default: return
        }
        
        let enabled = !textField996IsEmpty && !textField997IsEmpty && !textField998IsEmpty && !textField999IsEmpty
        
        changePasswordAction?.enabled = enabled
    }
    
    private func addBlurView() {
        
        guard let topView = UIApplication.topMostViewController?.view else { return }

        blurView?.removeFromSuperview()
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.alpha = 0
        topView.addSubview(blurView)
        blurView.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        })
        
        UIView.animateWithDuration(0.3) { 
            self.blurView?.alpha = 1
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(removeBlurView))
        blurView.addGestureRecognizer(recognizer)
    }
    
    @objc private func removeBlurView() {
        UIView.animateWithDuration(0.3, animations: {
            self.blurView?.alpha = 0
            }) { (_) in
                self.blurView?.removeFromSuperview()
                self.blurView = nil
        }
    }
    
}


// MARK:  Change Username

extension IBBSUserViewController {
    
    private func changeUsername() {
        
        let key = IBBSLoginKey()
        
        var usernameTF: UITextField!
        
        let alertVC = UIAlertController(title: CHANGE_USERNAME, message: CHECK_DIGITS_OF_USERNAME, preferredStyle: .Alert)
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.addTarget(self, action: #selector(IBBSUserViewController.changeUsernameTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
            
            textField.placeholder = HOLDER_USERNAME
            textField.enablesReturnKeyAutomatically = true
            usernameTF = textField
        }
        
        changeUsernameAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (action: UIAlertAction) -> Void in
            
            self.removeBlurView()
            
            guard let username = usernameTF.text where !username.isEmpty else { return }

            // ready to change username
            
            print(key.uid)
            print(key.token)
            print(username)
            print(key.username)
            
            APIClient.defaultClient.changeUsername(key.uid, username: username, old_username: key.username, token: key.token, success: { (json) in
                
                let model = IBBSModel(json: json)
                
                if model.success {
                    IBBSLoginKey.modifyUsername(json["new_username"].stringValue)
                }
                
                IBBSToast.make(model.message, delay: 0, interval: 3)
                
                }, failure: { (error) in
                    IBBSToast.make(ERROR_MESSAGE, delay: 0, interval: 3)
            })
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel) { (_) -> Void in
            
            self.removeBlurView()
            
            alertVC.dismissViewControllerAnimated(true , completion: nil)
        }
        
        changeUsernameAction?.enabled = false

        alertVC.addAction(changeUsernameAction)
        alertVC.addAction(cancelAction)
        
        self.addBlurView()
        
        UIApplication.topMostViewController?.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @objc private func changeUsernameTextFieldDidChange(textField: UITextField) {
        
        let isEmpty = textField.text?.isEmpty ?? true
        let count = textField.text?.utf8.count
        let enabled = !isEmpty && (count > 4 && count < 16)
        
        changeUsernameAction?.enabled = enabled
    }
}
