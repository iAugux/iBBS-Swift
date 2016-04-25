//
//  IBBSEffectViewController.swift
//  iBBS
//
//  Created by Augus on 9/26/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SnapKit

class IBBSEffectViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: BACKGROUNDER_IMAGE!)
        
        // blur view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.alpha = BLUR_VIEW_ALPHA_OF_BG_IMAGE
        view.addSubview(blurView)
        blurView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(IBBSEffectViewController.blurViewDidTap))
        blurView.addGestureRecognizer(gesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func blurViewDidTap() {
        dismissViewControllerAnimated(true , completion: nil)
    }
    
}
