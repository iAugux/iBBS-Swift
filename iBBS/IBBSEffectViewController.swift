//
//  IBBSEffectViewController.swift
//  iBBS
//
//  Created by Augus on 9/26/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSEffectViewController: UIViewController {
    
    var blurView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: BACKGROUNDER_IMAGE!)
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = view.frame
        blurView.alpha = BLUR_VIEW_ALPHA_OF_BG_IMAGE
        let gesture = UITapGestureRecognizer(target: self, action: #selector(IBBSEffectViewController.blurViewDidTap))
        blurView.addGestureRecognizer(gesture)
        view.addSubview(blurView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func blurViewDidTap(){
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        blurView.frame = CGRectMake(0, 0, 750, 750)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        blurView.frame = view.frame
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
