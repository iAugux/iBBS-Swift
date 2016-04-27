//
//  UIColor+Additions.swift
//  iBBS
//
//  Created by Augus on 9/4/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)        
    }
    
    class func randomColorFilterDarkerOut() -> UIColor {
        var h = CGFloat(0)
        var s = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        randomColor().getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        b = CGFloat(arc4random_uniform(10) + 5) / 10  // 0.5 < b < 1.0
        return UIColor(hue: h, saturation: s * 0.4, brightness: b, alpha: a)
    }
    
    func darkerColor(delta: CGFloat) -> UIColor {
        var h = CGFloat(0)
        var s = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * delta, alpha: a)
    }
    
    func lighterColor(delta: CGFloat) -> UIColor {
        var h = CGFloat(0)
        var s = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s * delta, brightness: b, alpha: a)
    }
    
}
