//
//  UIScreen+Extension.swift
//
//  Created by Augus on 9/8/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

extension UIScreen {
    
    class var width: CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
    
    class var height: CGFloat {
        return UIScreen.mainScreen().bounds.height
    }

}