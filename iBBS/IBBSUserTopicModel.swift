//
//  IBBSUserTopicModel.swift
//  iBBS
//
//  Created by Augus on 5/4/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


struct IBBSUserTopicModel {
    
    var board: String!
    var title: String!
    var postTime: String!
    
    init(json: JSON) {
        board     = json["board"].stringValue
        title     = json["title"].stringValue
        postTime  = json["post_time"].stringValue
    }
}