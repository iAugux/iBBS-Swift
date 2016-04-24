//
//  IBBSToken.swift
//  iBBS
//
//  Created by Augus on 4/24/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import Foundation


struct IBBSToken {
    
    var uid: String!
    var token: String!
    var expiry: NSDate!
    
    init(uid: String, token: String, expiry: NSDate) {
        self.uid    = uid
        self.token  = token
        self.expiry = expiry
    }
    
    var isValid: Bool {
        
        guard token != nil else { return false }
        
        return expiry.timeIntervalSinceNow > 0
    }
}