//
//  UIApplication+Additions.swift
//  iBBS
//
//  Created by Augus on 9/26/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit


extension UIApplication {
    class func topMostViewController() -> UIViewController? {
        var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
    
}