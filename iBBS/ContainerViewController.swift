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


enum SlideOutState {
    case collapsed
    case LeftPanelExpanded
}


class ContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // 0 ~ 320
    let centerPanelExpandedOffset: CGFloat = kScreenWidth - kExpandedOffSet
    var centerVCFrontBlurView: UIVisualEffectView!
    var centerNavigationController: UINavigationController!
    var mainViewController: UIViewController!
    var leftViewController: SlidePanelViewController?
    var currentState: SlideOutState = .collapsed {
        didSet {
            let shouldShowShadow = currentState != .collapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureBlurView()
        mainViewController = UIStoryboard.mainViewController()
        centerNavigationController = UINavigationController(rootViewController: mainViewController)
        centerNavigationController.setNavigationBarHidden(true , animated: false)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)

        self.configureGestureRecognizer()
       
    }
    

    func configureBlurView(){
        //        centerVCFrontBlurView = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        let viewEffect = UIBlurEffect(style: .Light)
        centerVCFrontBlurView = UIVisualEffectView(effect: viewEffect)
        centerVCFrontBlurView.alpha = 0.9
        centerVCFrontBlurView.frame = self.view.bounds

    }
    
    func configureGestureRecognizer(){
        let panGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.edges = UIRectEdge.Left
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
//        panGestureRecognizer.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SlidePanelViewController) {
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(kScreenWidth - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { finished in
                self.currentState = .collapsed
                
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController?.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController?.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController?.view.layer.shadowOpacity = 0
        }
    }
    
    func menuSelected(index: Int) {
        if index == 0 {
            centerNavigationController.viewControllers[0] = mainViewController
        }
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        collapseSidePanels()
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        switch(recognizer.state) {
        case .Began:
            mainViewController.view.addSubview(centerVCFrontBlurView)
            mainViewController.navigationController?.setNavigationBarHidden(true , animated: false)
            if (currentState == .collapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                    showShadowForCenterViewController(true)
                }
            }
        case .Changed:
            let pointX = centerNavigationController.view.frame.origin.x
            if (gestureIsDraggingFromLeftToRight || pointX > 0){
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
    
    func handleTapGesture(){
        if leftViewController != nil {
            animateLeftPanel(false)
            self.centerVCFrontBlurView.removeFromSuperview()
        }
    }
    
    // close left panel
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if leftViewController != nil{
            animateLeftPanel(false)
            self.centerVCFrontBlurView.removeFromSuperview()
        }
    }
    
    
    
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> SlidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SlidePanelViewController
    }
    
    class func mainViewController() -> TabBarController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("tabBarController") as? TabBarController
    }
}