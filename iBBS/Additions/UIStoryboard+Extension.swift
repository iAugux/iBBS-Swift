//
//  UIStoryboard+Extension.swift
//
//  Created by Augus on 4/30/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit


extension UIStoryboard {
    
    static var Main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class var SlidePanel: UIStoryboard {
        return UIStoryboard(name: "SlidePanel", bundle: nil)
    }
    
    class var User: UIStoryboard {
        return UIStoryboard(name: "User", bundle: nil)
    }
}