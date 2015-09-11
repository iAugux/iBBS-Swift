//
//  NodesContext.swift
//  iBBS
//
//  Created by Augus on 9/10/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation
import SwiftyJSON

class NodesContext {
    private let nodesId = "nodes"
    
    static let sharedInstance = NodesContext()
    
    func saveNodes(nodes:AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(nodes), forKey: nodesId)
        userDefaults.synchronize()
    }
    
    func getNodes() -> JSON? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data: AnyObject? = userDefaults.objectForKey(nodesId)
        if let obj: AnyObject = data {
            let json: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(obj as! NSData)
            return JSON(json!)
        } else {
            return nil
        }
    }

}