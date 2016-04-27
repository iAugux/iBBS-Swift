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
    var title: String!
    
    init(json: JSON) {
        id    = json["id"].intValue
        title = json["title"].stringValue
    }
}