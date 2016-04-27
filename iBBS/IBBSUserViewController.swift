//
//  IBBSUserViewController.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit

class IBBSUserViewController: UIViewController {
    
    var user: User!
    
    private let segueIdentifier = "GoToChatViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userImageView: IBBSAvatarImageView! {
        didSet {
            userImageView.layer.cornerRadius = userImageView.frame.width / 2
            userImageView.userInteractionEnabled = false
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
        
        configureViewsIfSelf()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == segueIdentifier else { return }
        
        guard let vc = segue.destinationViewController as? IBBSChatViewController else { return }
        
        vc.receiver = user
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
    
    @objc private func showActionSheet() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let passwdAction = UIAlertAction(title: CHANGE_PASSWORD, style: .Default) { (_) in
            self.changePassword()
        }
        
        let avatarAction = UIAlertAction(title: CHANGE_AVATAR, style: .Default) { (_) in
            self.changeAvatar()
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
        
        alertController.addAction(passwdAction)
        alertController.addAction(avatarAction)
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


extension IBBSUserViewController {
    
    private func secureAndAutoReturn(textField: UITextField) {
        textField.secureTextEntry = true
        textField.enablesReturnKeyAutomatically = true
    }
    
    private func changePassword() {
        
        var oldTF, newTF, confirmTF: UITextField!
        
        let alertVC = UIAlertController(title: CHANGE_PASSWORD, message: nil, preferredStyle: .Alert)
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = OLD_PASSWORD
            textField.secureAndAutoReturn()
            oldTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = HOLDER_PASSWORD
            textField.secureAndAutoReturn()
            newTF = textField
        }
        
        alertVC.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = CONFIRM_PASSWORD
            textField.secureAndAutoReturn()
            confirmTF = textField
        }
        
//        let okAction = UIAlertAction(title: BUTTON_OK, style: .Default) { (action: UIAlertAction) -> Void in
//            
//            guard let old = oldTF.text?.MD5(), let new = newTF.text?.MD5(), let confirm = confirmTF.text?.MD5() else {
//                
//                return
//            }
//            
//            guard new == confirm else {
//                let msg = NSLocalizedString("Passwords are not correct!", comment: "")
//                IBBSToast.make(msg, delay: 0, interval: 3)
//                return
//            }
//            
//            guard old != new else {
//                let msg = NSLocalizedString("Please set a new password!", comment: "")
//                IBBSToast.make(msg, delay: 0, interval: 3)
//                return
//            }
//            
//            
//            APIClient.sharedInstance.userLogin(username.text!, passwd: encryptedPasswd!, success: { (json) -> Void in
//                
//                let model = IBBSLoginModel(json: json)
//                
//                // something wrong , alert!!
//                if model.code == 0 {
//                    let alert = UIAlertController(title: ERROR_MESSAGE, message: model.message, preferredStyle: UIAlertControllerStyle.Alert)
//                    let cancelAction = UIAlertAction(title: TRY_AGAIN, style: .Cancel, handler: { (_) -> Void in
//                        self.changePassword()
//                        alertVC.dismissViewControllerAnimated(true , completion: nil)
//                    })
//                    
//                    alert.addAction(cancelAction)
//                    UIApplication.topMostViewController?.presentViewController(alert, animated: true, completion: nil)
//                    
//                } else {
//                    // success , keep token and other info
//                    IBBSLoginKey.saveTokenJson(json.object)
//                }
//                
//                
//            }) { (error ) -> Void in
//                DEBUGLog(error)
//            }
//        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel) { (_) -> Void in
            alertVC.dismissViewControllerAnimated(true , completion: nil)
        }
        
//        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        UIApplication.topMostViewController?.presentViewController(alertVC, animated: true, completion: nil)

    }
    
    private func changeAvatar() {
        
    }
}


private extension UITextField {
    
    func secureAndAutoReturn() {
        secureTextEntry = true
        enablesReturnKeyAutomatically = true
    }
}
