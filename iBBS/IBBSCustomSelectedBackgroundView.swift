//
//  IBBSCustomSelectedBackgroundView.swift
//  iBBS
//
//  Created by Augus on 10/6/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation



class IBBSCustomSelectedBackgroundView: UIView {
    
    override func drawRect(rect: CGRect) {
        let aRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(aRef)
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: 8.0)
        bezierPath.lineWidth = 8.0
        UIColor.whiteColor().setStroke()
        
        let fillColor = CUSTOM_THEME_COLOR.darkerColor(0.75)
        fillColor.setFill()
        
        bezierPath.stroke()
        bezierPath.fill()
        CGContextRestoreGState(aRef)
    }


}