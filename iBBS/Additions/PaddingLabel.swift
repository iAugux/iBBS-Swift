//
//  PaddingLabel.swift
//
//  Created by Augus on 4/16/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    
    var padding = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, padding))
    }
    
    // Override -intrinsicContentSize: for Auto layout code
    override func intrinsicContentSize() -> CGSize {
        let superContentSize = super.intrinsicContentSize()
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
    // Override -sizeThatFits: for Springs & Struts code
    override func sizeThatFits(size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + padding.left + padding.right
        let heigth = superSizeThatFits.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
}