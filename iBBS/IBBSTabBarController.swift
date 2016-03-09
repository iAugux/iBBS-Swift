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
       
        changeStatusBarColorOnSwipe()
        tabBar.items?[0].title = TITLE_HOME
        tabBar.items?[1].title = TITLE_NODE
        tabBar.items?[2].title = TITLE_MESSAGE
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.tintColor = CUSTOM_THEME_COLOR
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarView?.frame = UIApplication.sharedApplication().statusBarFrame
    }
    
    func changeStatusBarColorOnSwipe(){
        if SHOULD_HIDE_NAVIGATIONBAR {
            statusBarView = UIToolbar(frame: UIApplication.sharedApplication().statusBarFrame)
            statusBarView.barStyle = UIBarStyle.Default
            view.addSubview(statusBarView)

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
