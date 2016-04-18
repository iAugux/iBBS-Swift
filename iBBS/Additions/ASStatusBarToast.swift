//
//  ASStatusBarToast.swift
//
//  Created by Augus on 4/17/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit


/// Not support orientation

class ASStatusBarToast: NSObject {
    
    private static var statusBarFrame: CGRect {
        var frame = UIApplication.sharedApplication().statusBarFrame
        frame = frame == CGRectZero ? CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 20) : frame
        return frame
    }
    
    private static var topWindow: UIWindow = {
       let w = UIWindow(frame: UIScreen.mainScreen().bounds)
        w.windowLevel            = UIWindowLevelStatusBar + 1
        w.backgroundColor        = UIColor(red: 0.7356, green: 0.4022, blue: 0.4019, alpha: 0.0)
        w.userInteractionEnabled = false
        w.makeKeyAndVisible()
        return w
    }()
    
    private static var statusBarToast: UILabel = {
        let label = UILabel(frame: statusBarFrame)
        label.textAlignment = .Center
        return label
    }()
    
}


extension ASStatusBarToast {
    
    static func makeStatusBarToast(text: String,
                                   delay: NSTimeInterval = 0,
                                   interval: NSTimeInterval = 2,
                                   bgColor: UIColor? = nil,
                                   textColor: UIColor = .whiteColor(),
                                   font: UIFont = UIFont.systemFontOfSize(12.0)) {
        
        let window = topWindow
        
        var originalFrame = statusBarFrame
        originalFrame.origin.y -= originalFrame.height
        
        let label             = ASToastLabel(frame: originalFrame)
        label.text            = text
        label.textColor       = textColor
        label.font            = font
        label.backgroundColor = bgColor ?? CUSTOM_THEME_COLOR
        window.addSubview(label)
        
        UIView.animateWithDuration(1.0, delay: delay, options: [], animations: { 
            label.frame = statusBarFrame
            }, completion: { _ in
                UIView.animateWithDuration(1.0, delay: interval, options: [], animations: { 
                    label.frame = originalFrame
                    }, completion: { _ in
                        window.removeFromSuperview()
                })
        })
    }
}


private class ASToastLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .Center
        textColor = UIColor.whiteColor()
        font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}