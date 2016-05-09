//
//  IBBSNodeModel.swift
//  iBBS
//
//  Created by Augus on 4/26/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


struct IBBSNodeModel {
    
    var id: Int!
    var name: String!
    var numberOfTotal: Int!
    var numberOfToday: Int!
    
    init(json: JSON) {
        id            = json["id"].intValue
        name          = json["name"].stringValue
        numberOfTotal = json["post_num"].intValue
        numberOfToday = json["post_today"].intValue
    }
}