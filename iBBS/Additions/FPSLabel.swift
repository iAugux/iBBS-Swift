//
//  FPSLabel.swift
//
//  Created by Augus on 4/13/16.
//  Copyright © 2016 iAugus. All rights reserved.
//


import UIKit

//REFERENCE: https://github.com/ibireme/YYText/blob/master/Demo/YYTextDemo/YYFPSLabel.m

class FPSLabel: UILabel {
    
    private var link: CADisplayLink!
    private lazy var count: Int = 0
    private lazy var lastTime: NSTimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        center = CGPointMake(18, UIScreen.mainScreen().bounds.height - 40)
        
        if frame != CGRectZero {
            self.frame = frame
        }
        
        layer.cornerRadius     = 5
        clipsToBounds          = true
        textAlignment          = .Center
        textColor              = UIColor.whiteColor()
        backgroundColor        = UIColor(white: 0, alpha: 0.7)
        font                   = UIFont(name: "HelveticaNeue", size: 14)
        userInteractionEnabled = false
        
        weak var weakSelf = self
        link = CADisplayLink(target: weakSelf!, selector:#selector(FPSLabel.tick(_:)) );
        link.addToRunLoop(NSRunLoop .mainRunLoop(), forMode:NSRunLoopCommonModes)
    }
    
    convenience init(center: CGPoint) {
        self.init()
        self.center = center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sizeToFit()
    }
    
    @objc private func tick(link: CADisplayLink) {
        
        if lastTime == 0  {
            lastTime = link.timestamp
            return
        }
        
        count += 1
        let delta = link.timestamp - lastTime
        
        guard delta >= 1 else { return }
        
        lastTime = link.timestamp
        let fps = Double(count) / delta
        count = 0
        
        let progress = fps / 60.0;
        textColor = UIColor(hue: CGFloat(0.27 * (progress - 0.2)), saturation: 1, brightness: 0.9, alpha: 1)
        text = "\(Int(fps + 0.5)) FPS  "
    }
    
}
