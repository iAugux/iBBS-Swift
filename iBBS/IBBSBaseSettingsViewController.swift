//
//  IBBSBaseSettingsViewController.swift
//  iBBS
//
//  Created by Augus on 10/10/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSBaseSettingsViewController: UIViewController {
    
    private var navBar: UINavigationBar!
    private var popButton: UIButton!
    
    private let navBarHeight: CGFloat = 44.0
    
    override func loadView() {
        super.loadView()
        manuallyConfigureTopBar()
        configureScreenEdgePanGesture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func popViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func manuallyConfigureTopBar() {
        
        navBar = UINavigationBar()
        let image = UIImage(named: "back_button")
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height

        navBar.barStyle = .Default
        navBar.translucent = true
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]
        navBar.setItems([UINavigationItem(title: title ?? "")], animated: false)
//        navBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(popViewController))
        view.addSubview(navBar)
        navBar.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(statusBarHeight + navBarHeight)
        }
        
        // custom pop button
        popButton = UIButton(type: .Custom)
        popButton.setImage(image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        popButton.tintColor = CUSTOM_THEME_COLOR
        popButton.addTarget(self, action: #selector(popViewController), forControlEvents: .TouchUpInside)
        navBar.addSubview(popButton)
        popButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(26)
            make.left.equalTo(6)
            make.bottom.equalTo(-8)
        }
    }
    
    private func configureScreenEdgePanGesture() {
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popViewController))
        recognizer.edges = UIRectEdge.Left
        view.addGestureRecognizer(recognizer)
    }
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        guard !UIDevice.isPad else { return }
        guard navBar != nil else { return }
        
        let statusBarHeight = 20 - UIApplication.sharedApplication().statusBarFrame.height
        
        navBar.snp_updateConstraints { (make) in
            make.height.equalTo(statusBarHeight + navBarHeight)
        }
        
        popButton?.snp_updateConstraints(closure: { (make) in
            
            if statusBarHeight > 0 {
                make.width.height.equalTo(26)
                make.bottom.equalTo(-8)
            } else {
                make.width.height.equalTo(22)
                make.bottom.equalTo(-6)
            }
        })
    }

}
