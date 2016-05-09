//
//  IBBSModel.swift
//  iBBS
//
//  Created by Augus on 4/24/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


struct IBBSModel {
    
    var success: Bool
    var message: String!
    
    init(json: JSON?) {
        if json != nil {
            success = json!["code"].boolValue
            message = json!["msg"].stringValue
        } else {
            success = false
            message = ""
        }
    }
}