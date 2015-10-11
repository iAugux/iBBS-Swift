//
//  UIImageView+Additions.swift
//  iBBS
//
//  Created by Augus on 10/11/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation


extension UIImageView {
    
    func changeColorForImageOfImageView(tintColor: UIColor) {
        self.image = self.image?.imageWithRenderingMode(.AlwaysTemplate)
        self.tintColor = tintColor
    }
    
    
}