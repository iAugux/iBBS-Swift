//
//  IBBSSettingContainerViewController.swift
//  iBBS
//
//  Created by Augus on 5/5/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit

class IBBSSettingContainerViewController: UITableViewController {

    @IBOutlet weak var passcodeSwitch: UISwitch! {
        didSet {
            passcodeSwitch.onTintColor = CUSTOM_THEME_COLOR
        }
    }
    
    private let configuration: PasscodeLockConfigurationType!
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePasscodeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 1: changePasscode()
            
        default: return
        }
    }
    
    private func changePasscode() {
        
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
        
        presentViewController(passcodeLock, animated: true, completion: nil)
    }
    
    
    @IBAction func passcodeSwitchDidTap(sender: UISwitch) {
        
        let passcodeVC: PasscodeLockViewController
        
        if !configuration.repository.hasPasscode {
            
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
            
        } else {
            
            passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
            
            passcodeVC.successCallback = { lock in
                
                lock.repository.deletePasscode()
                self.updatePasscodeView()
            }
        }
        
        presentViewController(passcodeVC, animated: true, completion: nil)
    }

    private func updatePasscodeView() {
        let hasPasscode = configuration.repository.hasPasscode
        passcodeSwitch.on = hasPasscode
    }
}
