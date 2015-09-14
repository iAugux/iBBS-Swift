//
//  UserDefaults.swift
//  iBBS
//
//  Created by Augus on 9/14/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation

class UserDefaults {
    
    static let sharedInstance = UserDefaults()
    
    func getLoginData() -> [String: AnyObject?] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let token = userDefaults.objectForKey("currentUserToken")
        let username = userDefaults.objectForKey("currentUserName")
        let avatar = userDefaults.objectForKey("currentUserAvatarUrl")
        let data = ["token": token, "username": username, "avatar": avatar]
        return data
    }
    
    func getToken() -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let token = userDefaults.objectForKey("currentUserToken")
        return token as? String
    }
}