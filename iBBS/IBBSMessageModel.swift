//
//  IBBSMessageModel.swift
//  iBBS
//
//  Created by Augus on 4/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


struct IBBSMessageModel {
    
    var id: Int!
    var avatarUrl: NSURL!
    var sender: String!
    var senderUid: Int!
    var content: String!
    var sendTime: String!
    var isRead: Bool!
    var isAdministrator: Bool!
    
    init(json: JSON) {
        avatarUrl       = NSURL(string: json["sender_avatar"].stringValue)
        id              = json["id"].intValue
        sender          = json["sender"].stringValue
        senderUid       = json["sender_uid"].intValue
        content         = json["title"].stringValue
        sendTime        = json["send_time"].stringValue
        isRead          = json["is_read"].intValue == 0 ? true : false
        isAdministrator = json["type"].boolValue
    }
}


struct IBBSReadMessageModel {
    
    var username: String!
    var title: String!
    var content: String!
    
    init(json: JSON) {
        username = json["msg"]["username"].stringValue
        content  = json["msg"]["content"].stringValue
        title    = json["title"].stringValue
    }
}
