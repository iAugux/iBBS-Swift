//
//  AppDelegate.swift
//  iBBS
//
//  Created by Augus on 9/1/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//


import UIKit
import Kingfisher


let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var containerViewController: ContainerViewController!
    
    lazy var passcodeLockPresenter: PasscodeLockPresenter = {
        
        let configuration = PasscodeLockConfiguration()
        let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration)
        
        return presenter
    }()

    
    #if DEBUG
    let fps = FPSLabel(center: CGPointMake(3, 20))
    #endif

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
        // Touch ID
        passcodeLockPresenter.presentPasscodeLock()

        // SlideMenu
        application.statusBarStyle = .LightContent
        containerViewController = ContainerViewController()
        
        let homeNav = UIStoryboard.Main.instantiateViewControllerWithIdentifier(String(RootNavigationController)) as! UINavigationController
        homeNav.viewControllers[0] = containerViewController
        homeNav.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = homeNav
        
        
        // Settings
        
        if isIphone3_5Inch {
            SHOULD_HIDE_NAVIGATIONBAR = true
        }
        
        // Set Theme
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let theme = userDefaults.objectForKey(kCurrentTheme) {
            IBBSThemes(rawValue: Int(theme as! NSNumber))?.setTheme()
            setWindowColor()
            
        } else {
            let theme = IBBSThemes.GreenTheme
            theme.setTheme()
            setWindowColor()

        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setWindowColor), name: kThemeDidChangeNotification, object: nil)
        
        
        let cache = KingfisherManager.sharedManager.cache
        // Set max disk cache to 50 mb.
        cache.maxDiskCacheSize = 50 * 1024 * 1024
        
        
        #if DEBUG
//            window?.addSubview(fps)
        #endif
        
        return true
    }
    
    @objc private func setWindowColor() {
        window?.tintColor = CUSTOM_THEME_COLOR
        window?.backgroundColor = CUSTOM_THEME_COLOR.lighterColor(0.6)

    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        passcodeLockPresenter.presentPasscodeLock()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

