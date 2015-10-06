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

import Foundation

extension UIColor {
    class func randomColor() -> UIColor{
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)        
    }
    
    func darkerColor(delta: CGFloat) -> UIColor {
        var h = CGFloat(0)
        var s = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * delta, alpha: a)
    }
    
    
}
