//
//  IBBSAvatarImageView.swift
//  iBBS
//
//  Created by Augus on 11/3/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SnapKit


struct User {
    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

private let overlayImage: UIImage = {
    let radius: CGFloat = 15
    let innerSize = CGSizeMake(30, 30)
    let image = UIGraphicsDrawAntiRoundedCornerImageWithRadius(radius, outerSize: innerSize, innerSize: innerSize, fillColor: UIColor.whiteColor())
    return image
}()

class IBBSAvatarImageView: UIImageView {
    
    var user: User!
    
    var antiOffScreenRendering: Bool = true {
        didSet {
            guard !antiOffScreenRendering else { return }
            guard let _ = overlayView?.removeFromSuperview() else { return }
            
            layer.cornerRadius = frame.width / 2
            layoutIfNeeded()
        }
    }
    
    private var overlayView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds       = true
        backgroundColor     = UIColor.randomColorFilterDarkerOut()
        
        overlayView = UIImageView()
        overlayView.image = overlayImage
        overlayView.contentMode = .ScaleToFill
        addSubview(overlayView)
        overlayView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        }

        userInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(IBBSAvatarImageView.avatarDidTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc private func avatarDidTap() {
        
        guard user != nil else { return }
        
        guard let nav = UIStoryboard.User.instantiateViewControllerWithIdentifier("UserNavigationViewController") as? UINavigationController else { return }
        
        guard let vc = nav.viewControllers.first as? IBBSUserViewController else { return }

        vc.user = user
        
        UIApplication.topMostViewController?.presentViewController(nav, animated: true, completion: nil)
    }
    
}