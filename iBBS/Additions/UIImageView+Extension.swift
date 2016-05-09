//
//  UIImageView+Extension.swift
//
//  Created by Augus on 10/11/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation


extension UIImageView {
    
    func changeImageColor(tintColor: UIColor) {
        self.image = self.image?.imageWithRenderingMode(.AlwaysTemplate)
        self.tintColor = tintColor
    }
    
    func changeImageWithAnimation(name: String, duration: NSTimeInterval = 1.0, animation: Bool = true) {
        
        let img = UIImage(named: name)
        _changeImageWithAnimation(img, duration: duration, animation: animation)
    }
    
    func _changeImageWithAnimation(img: UIImage?, duration: NSTimeInterval = 1.0, animation: Bool = true) {
        
        if animation {
            let transition = CATransition()
            transition.duration = duration
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            layer.addAnimation(transition, forKey: nil)
        }
        
        // change image now
        image = img
    }
    
}
