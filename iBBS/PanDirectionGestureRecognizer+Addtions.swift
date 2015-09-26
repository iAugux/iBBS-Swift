//
//  PanDirectionGestureRecognizer+Addtions.swift
//  TinderSwipeCellSwift
//
//  Created by Augus on 8/23/15.
//  Copyright © 2015 iAugus. All rights reserved.
//  http://stackoverflow.com/a/30607392/4656574

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum PanDirection {
    case Vertical
    case Horizontal
}

class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
    
    let direction : PanDirection
    
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        if state == .Began {
            let velocity = velocityInView(self.view!)
            switch direction {
                
            case .Horizontal where fabs(velocity.y) > fabs(velocity.x):
                state = .Cancelled
            case .Vertical where fabs(velocity.x) > fabs(velocity.y):
                state = .Cancelled
            default:
                break
            }
        }

    }
  
}