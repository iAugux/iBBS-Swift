//
//  IBBSAvatarImageView.swift
//  iBBS
//
//  Created by Augus on 11/3/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit


struct User {
    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

class IBBSAvatarImageView: UIImageView {
    
    var user: User!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds       = true
//        layer.borderWidth   = 0.3
//        layer.borderColor   = UIColor.blackColor().CGColor
        layer.cornerRadius  = frame.width / 2.0
        backgroundColor     = UIColor.randomColorFilterDarkerOut()
        
        userInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(IBBSAvatarImageView.avatarDidTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc private func avatarDidTap() {
        
        guard let nav = MainStoryboard.instantiateViewControllerWithIdentifier("UserNavigationViewController") as? UINavigationController else { return }
        guard let vc = nav.viewControllers.first as? IBBSUserViewController else { return }

        guard user != nil else { return }
        
        vc.user = user
        
        UIApplication.topMostViewController?.presentViewController(nav, animated: true, completion: nil)
    }
    
}