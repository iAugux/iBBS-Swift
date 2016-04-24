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
    var code: Int!
    var expire: NSDate!
    var avatar: NSURL!
    var userId: String!
    var username: String!
    
    init(json: JSON) {
        message = json["msg"].stringValue
        token = json["token"].stringValue
        code = json["code"].intValue
        expire = NSDate(timeIntervalSince1970: json["expire"].doubleValue)
        avatar = NSURL(string: json["avatar"].stringValue)
        userId = json["uid"].stringValue
        username = json["username"].stringValue
    }
}