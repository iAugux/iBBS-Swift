//
//  IBBSTopicListModel.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON



struct IBBSTopicListModel {
    
    var board: String!
    var title: String!
    var uid: Int!
    var username: String!
    var postTime: String!
    var avatarUrl: NSURL!
    
    init(json: JSON) {
        board     = json["board"].stringValue
        title     = json["title"].stringValue
        uid       = json["uid"].intValue
        username  = json["username"].stringValue
        postTime  = json["post_time"].stringValue
        avatarUrl = NSURL(string: json["avatar"].stringValue)
    }
}