//
//  CAAnimation+Additions.swift
//  iBBS
//
//  Created by Augus on 10/10/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentViewControllerLikePushAnimation(destinationVC: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        
        self.presentViewController(destinationVC, animated: false, completion: nil)
        
    }
    
    func dismissViewControllerLikePopAnimation() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        
        self.dismissViewControllerAnimated(false , completion: nil)
    }
    
    
}