//
//  BaseViewController.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseViewController: UIViewController {
    struct VCIdentifiers {
        static let mainDetailVC = "mainDetailViewController"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeStatusBarColorOnSwipe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var datasource: Array<JSON>!{
        didSet{
//            print(datasource)
            
        }
    }
    
    // after swiping, navigation bar has  been hidden, but background color of status bar is clearColor, so I need to set status bar' color to navigation bar' tintcolor
    func changeStatusBarColorOnSwipe(){
        let statusBarView: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, kScreenWidth, 22))
        statusBarView.barStyle = UIBarStyle.Default
        //        statusBarView.barTintColor = UIColor.redColor()
        
        self.view.addSubview(statusBarView)
    }
    
}
