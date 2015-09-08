//
//  RootNavigationViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit



public class ENSideMenuNavigationController: UINavigationController, ENSideMenuProtocol{
    
    public var sideMenu : ENSideMenu?
    public var sideMenuAnimationType : ENSideMenuAnimation = .Default
    public var dismissView: UIVisualEffectView!
    
    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func loadView() {
        super.loadView()
        configureDismissView()
    }
    
    public init( menuViewController: UIViewController, contentViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        if (contentViewController != nil) {
            self.viewControllers = [contentViewController!]
        }
        
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: menuViewController, menuPosition:.Left)
        view.bringSubviewToFront(navigationBar)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    public func setContentViewController(contentViewController: UIViewController) {
        self.sideMenu?.toggleMenu()
        switch sideMenuAnimationType {
        case .None:
            self.viewControllers = [contentViewController]
            break
        default:
            contentViewController.navigationItem.hidesBackButton = true
            self.setViewControllers([contentViewController], animated: true)
            break
        }
        
    }
    
    func configureDismissView(){
        dismissView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))

        dismissView.frame = self.view.bounds
        dismissView.alpha = 0.9
        
        self.view.addSubview(dismissView)
        dismissView.hidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissViewDidTap")
        self.dismissView.addGestureRecognizer(tapGesture)
    }
    
    public func dismissViewOpen() {
        dismissView.hidden = false
    }
    
    public func dismissViewClose() {
        dismissView.hidden = true
    }
    
    public func dismissViewDidTap(){
        sideMenu?.hideSideMenu()
        print("dismissView did tap")
    }
    
    
}
