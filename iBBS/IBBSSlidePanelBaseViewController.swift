//
//  IBBSSlidePanelBaseViewController.swift
//  iBBS
//
//  Created by Augus on 10/10/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSSlidePanelBaseViewController: UIViewController {
    
    
    
    override func loadView() {
        super.loadView()
        manuallyConfigureTopBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        manuallyConfigureTopBar()
        configureScreenEdgePanGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func manuallyConfigureTopBar() {
//        // add status bar view
//        let statusBarView = UIToolbar(frame:  UIApplication.sharedApplication().statusBarFrame)
//        statusBarView.barStyle = .Default
//        statusBarView.translucent = true
//        view?.addSubview(statusBarView)
        
        // add navigation bar
//        let navBar = UINavigationBar(frame: CGRectMake(0.0, 20.0, UIScreen.screenWidth(), 44.0))
        let navBar = UINavigationBar(frame: CGRectMake(0.0, 0.0, UIScreen.screenWidth(), 64.0))

        navBar.barStyle = .Default
        navBar.translucent = true
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]
        navBar.setItems([UINavigationItem(title: title ?? "")], animated: false)
        navBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button"), style: .Plain, target: self, action: #selector(IBBSSlidePanelBaseViewController.popViewController))
        view.addSubview(navBar)
    }
    
    func popViewController() {
        navigationController?.popViewControllerAnimated(true)
      
    }
    
    func configureScreenEdgePanGesture() {
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(IBBSSlidePanelBaseViewController.popViewController))
        recognizer.edges = UIRectEdge.Left
        view.addGestureRecognizer(recognizer)
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
