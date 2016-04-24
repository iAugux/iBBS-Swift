//
//  IBBSNodeTopicListModel.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


struct IBBSNodeTopicListModel {
    
    var title: String!
    var username: String!
    var postTime: String!
    var avatarUrl: NSURL!
    
    init(json: JSON) {
        title     = json["title"].stringValue
        username  = json["username"].stringValue
        postTime  = json["post_time"].stringValue
        avatarUrl = NSURL(string: json["avatar"].stringValue)
    }
    
}