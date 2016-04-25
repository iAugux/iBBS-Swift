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
import SnapKit


class TabBarController: UITabBarController {
    
    private var statusBarView: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        changeStatusBarColorOnSwipe()
        tabBar.items?[0].title = TITLE_HOME
        tabBar.items?[1].title = TITLE_NODE
        tabBar.items?[2].title = TITLE_MESSAGE
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(changeTabBarTintColor), name: kThemeDidChangeNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarView?.frame = UIApplication.sharedApplication().statusBarFrame
    }
    
    private func changeStatusBarColorOnSwipe() {
        
        if SHOULD_HIDE_NAVIGATIONBAR {
            statusBarView = UIToolbar(frame: UIApplication.sharedApplication().statusBarFrame)
            statusBarView.barStyle = UIBarStyle.Default
            view.addSubview(statusBarView)
        }
    }
    
    @objc private func changeTabBarTintColor() {
        tabBar.tintColor = CUSTOM_THEME_COLOR
    }

}
