//
//  RootNavigationController.swift
//  iBBS
//
//  Created by Augus on 9/5/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class RootNavigationController: ENSideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: NodesViewController(), menuPosition:.Right)
//        sideMenu?.delegate = self //optional
//        sideMenu?.menuWidth = 180.0 // optional, default is 160
        sideMenu?.bouncingEnabled = false
            
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
