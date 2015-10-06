//
//  TabBarController.swift
//  iBBS
//
//  Created by Augus on 9/12/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

var statusBarView: UIToolbar!

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeStatusBarColorOnSwipe()
        // Do any additional setup after loading the view.
        self.tabBar.items?[0].title = TITLE_HOME
        self.tabBar.items?[1].title = TITLE_NODE
        self.tabBar.items?[2].title = TITLE_MESSAGE
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.tintColor = CUSTOM_THEME_COLOR
    }

    func changeStatusBarColorOnSwipe(){
        if SHOULD_HIDE_NAVIGATIONBAR {
            statusBarView = UIToolbar(frame:  UIApplication.sharedApplication().statusBarFrame)
            statusBarView.barStyle = UIBarStyle.Default            
            self.view.addSubview(statusBarView)

        }
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
