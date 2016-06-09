//
//  IBBSLoginModel.swift
//  iBBS
//
//  Created by Augus on 4/24/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


struct IBBSLoginModel {
    
    var message: String!
    var token: String!
    var isAdmin: Bool!
    var success: Bool!
    var expire: NSDate!
    var avatar: NSURL!
    var userId: Int!
    var username: String!
    
    init(json: JSON) {
        message  = json["msg"].stringValue
        token    = json["token"].stringValue
        isAdmin  = json["is_admin"].boolValue
        success  = json["code"].boolValue
        expire   = NSDate(timeIntervalSince1970: json["expire"].doubleValue)
        avatar   = NSURL(string: json["avatar"].stringValue)
        userId   = json["uid"].intValue
        username = json["username"].stringValue
    }
}