//
//  IBBSToken.swift
//  iBBS
//
//  Created by Augus on 4/24/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


private let kLoginFeedbackJson = "kLoginFeedbackJson"

struct IBBSLoginKey {
    
    var uid: String!
    var token: String!
    var expiry: NSDate!
    var avatar: NSURL!
    var username: String!
    
    init() {
        
        guard let json = tokenJson else { return }
        
        let model = IBBSLoginModel(json: json)

        self.uid      = model.userId
        self.token    = model.token
        self.expiry   = model.expire
        self.avatar   = model.avatar
        self.username = model.username
    }
    
    var isValid: Bool {
        
        let toast = {
            IBBSToast.make(TOKEN_LOST_EFFECTIVENESS, interval: TIME_OF_TOAST_OF_TOKEN_ILLEGAL)
        }
        
        guard token != nil && uid != nil else {
            toast()
            return false
        }
        
        let vaild = expiry.timeIntervalSinceNow > 0
        
        if !vaild { toast() }
        
        return vaild
    }
    
    private var tokenJson: JSON? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey(kLoginFeedbackJson) else { return nil }
        
        guard let json = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) else { return nil }
        
        return JSON(json)
    }
    
    static func saveTokenJson(json: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(json), forKey: kLoginFeedbackJson)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

