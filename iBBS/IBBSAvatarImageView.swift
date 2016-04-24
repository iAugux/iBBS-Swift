//
//  IBBSAvatarImageView.swift
//  iBBS
//
//  Created by Augus on 11/3/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSAvatarImageView: UIImageView {
    
    var userId: String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds       = true
//        layer.borderWidth   = 0.3
//        layer.borderColor   = UIColor.blackColor().CGColor
        layer.cornerRadius  = frame.width / 2.0
        backgroundColor     = UIColor.randomColor()
        
        userInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(IBBSAvatarImageView.avatarDidTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc private func avatarDidTap() {
        
        guard let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UserNavigationViewController") as? UINavigationController else { return }
        guard let vc = nav.viewControllers.first as? IBBSUserViewController else { return }

        vc.userId = userId
        
        guard userId != nil else { return }
        
        UIApplication.topMostViewController?.presentViewController(nav, animated: true, completion: nil)
    }
    
}