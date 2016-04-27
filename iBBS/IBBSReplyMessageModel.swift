//
//  IBBSMessageModel.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON

struct IBBSReplyMessageModel {
    
    var avatarUrl: NSURL!
    var uid: Int!
    var username: String!
    var content: String!
    
    init(json: JSON) {
        avatarUrl = NSURL(string: json["avatar"].stringValue)
        uid       = json["uid"].intValue
        username  = json["username"].stringValue
        content   = json["comment_content"].stringValue
    }
}
