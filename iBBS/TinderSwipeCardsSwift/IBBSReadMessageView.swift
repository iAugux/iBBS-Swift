//
//  IBBSReadMessageView.swift
//  iBBS
//
//  Created by Augus on 9/17/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSReadMessageView: DraggableView {

    @IBOutlet var imageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.blackColor()
    }

}
