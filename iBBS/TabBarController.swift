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

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeStatusBarColorOnSwipe()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeStatusBarColorOnSwipe(){
        let statusBarView: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, kScreenWidth, 22))
        statusBarView.barStyle = UIBarStyle.Default
        //        statusBarView.barTintColor = UIColor.redColor()
        
        self.view.addSubview(statusBarView)
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
