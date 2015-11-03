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
        
        self.clipsToBounds       = true
        self.layer.borderWidth   = 0.3
        self.layer.borderColor   = UIColor.blackColor().CGColor
        self.layer.cornerRadius  = self.frame.width / 2.0
        self.backgroundColor     = UIColor.randomColor()
    }
}