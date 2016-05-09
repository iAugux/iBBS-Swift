//
//  ContainerViewController.swift
//  SlideMenu
//
//  Created by Augus on 4/27/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright (c) 2015 Augus. All rights reserved.
//


import UIKit

let kExpandedOffSet: CGFloat = 130.0

enum SlideOutState {
    case collapsed
    case LeftPanelExpanded
}

class ContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var centerVCFrontBlurView: UIVisualEffectView!
    private var centerNavigationController: UINavigationController!
    private var mainViewController: UIViewController!
    private var leftViewController: SlidePanelViewController?
    
    private var currentState: SlideOutState = .collapsed {
        didSet {
            let shouldShowShadow = currentState != .collapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlurView()
        mainViewController = UIStoryboard.mainViewController()
        centerNavigationController = UINavigationController(rootViewController: mainViewController)
        centerNavigationController.setNavigationBarHidden(true , animated: false)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        configureGestureRecognizer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureBlurView() {
        let viewEffect = UIBlurEffect(style: .Light)
        centerVCFrontBlurView = UIVisualEffectView(effect: viewEffect)
        centerVCFrontBlurView.alpha = 0.96
    }
    
    func configureGestureRecognizer() {
        
        let panGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.edges = UIRectEdge.Left
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        centerVCFrontBlurView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer.classForCoder()) {
            if (otherGestureRecognizer.view?.isKindOfClass(UIScrollView.classForCoder()) != nil){
                return true
            }
        }
        if (otherGestureRecognizer.view?.isKindOfClass(UITableView.classForCoder()) != nil){
            return true
        }
        return false
    }
    
    private func addLeftPanelViewController() {
        if leftViewController == nil {
            leftViewController = UIStoryboard.leftViewController()            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    private func addChildSidePanelController(sidePanelController: SlidePanelViewController) {
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    private func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(kExpandedOffSet)
        } else {
            animateCenterPanelXPosition(0) { finished in
                self.currentState = .collapsed
                
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    private func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController?.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    private func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController?.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController?.view.layer.shadowOpacity = 0
        }
    }
    
    private func menuSelected(index: Int) {
        if index == 0 {
            centerNavigationController.viewControllers[0] = mainViewController
        }
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        collapseSidePanels()
    }
    
    private func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        switch(recognizer.state) {
        case .Began:
            
            mainViewController.view.addSubview(centerVCFrontBlurView)
            centerVCFrontBlurView.snp_makeConstraints(closure: { (make) in
                make.edges.equalTo(UIEdgeInsetsZero)
            })
            
            mainViewController.navigationController?.setNavigationBarHidden(true , animated: false)
            
            if (currentState == .collapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                    showShadowForCenterViewController(true)
                }
            }
        case .Changed:
            let pointX = centerNavigationController.view.frame.origin.x
            if (gestureIsDraggingFromLeftToRight || pointX > 0) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
                
            }
        case .Ended:
            if leftViewController != nil{
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width / 1.5
                animateLeftPanel(hasMovedGreaterThanHalfway)
                if !hasMovedGreaterThanHalfway {
                    centerVCFrontBlurView.removeFromSuperview()

                }
            }
        default:
            break
        }
        
    }
    
    @objc private func handleTapGesture() {
        animateLeftPanel(false)
        centerVCFrontBlurView.removeFromSuperview()
        NSNotificationCenter.defaultCenter().postNotificationName(kShouldShowCornerActionButton, object: nil)
    }
    
    // close left panel
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if leftViewController != nil{
            animateLeftPanel(false)
            centerVCFrontBlurView.removeFromSuperview()
        }
    }
    
    internal func removeFrontBlurView(){
        centerVCFrontBlurView.removeFromSuperview()
    }
    
    internal func toggleLeftPanel() {
        
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(notAlreadyExpanded)
    }
}


private extension UIStoryboard {
    
    class func leftViewController() -> SlidePanelViewController? {
        return UIStoryboard.SlidePanel.instantiateViewControllerWithIdentifier(String(SlidePanelViewController)) as? SlidePanelViewController
    }
    
    class func mainViewController() -> TabBarController? {
        return UIStoryboard.Main.instantiateViewControllerWithIdentifier(String(TabBarController)) as? TabBarController
    }
}

