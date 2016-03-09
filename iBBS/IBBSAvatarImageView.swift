//
//  IBBSAvatarImageView.swift
//  iBBS
//
//  Created by Augus on 11/3/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation

class IBBSAvatarImageView: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds       = true
        layer.borderWidth   = 0.3
        layer.borderColor   = UIColor.blackColor().CGColor
        layer.cornerRadius  = frame.width / 2.0
        backgroundColor     = UIColor.randomColor()
    }
}