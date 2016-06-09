//
//  IBBSLoginKey.swift
//  iBBS
//
//  Created by Augus on 4/24/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import SwiftyJSON


private let kLoginFeedbackJson = "kLoginFeedbackJson"

struct IBBSLoginKey {
        
    var uid: Int!
    var token: String!
    var isAdmin: Bool!
    var expiry: NSDate!
    var sex: String!
    var avatar: NSURL!
    var username: String!
    var themeColor: UIColor!
    
    init() {
        
        guard let json = tokenJson else { return }
        
        let model = IBBSLoginModel(json: json)

        self.uid      = model.userId
        self.token    = model.token
        self.isAdmin  = model.isAdmin
        self.expiry   = model.expire
        self.avatar   = model.avatar
        self.username = model.username
    }
    
    var isValid: Bool {
        
        let toast = {
            IBBSToast.make(TOKEN_LOST_EFFECTIVENESS, interval: TIME_OF_TOAST_OF_TOKEN_ILLEGAL)
        }
        
        guard token != nil && uid != nil else {
            toast()
            return false
        }
        
        let vaild = expiry.timeIntervalSinceNow > 0
        
        if !vaild { toast() }
        
        return vaild
    }
    
    
    
    private var tokenJson: JSON? {
        guard let json = NSUserDefaults.standardUserDefaults().unarchiveObjectWithDataForKey(kLoginFeedbackJson) else { return nil }
        return JSON(json)
    }
    
    static func saveTokenJson(json: AnyObject) {
        NSUserDefaults.standardUserDefaults().setArchivedData(json, forKey: kLoginFeedbackJson)
    }
    
    static func modifyUsername(username: String) {
        
        guard let json = IBBSLoginKey().tokenJson else { return }
        
        guard var dic = json.dictionaryObject else { return }
        
        dic["username"] = username
        
        let newJson = JSON(dic)
        
        saveTokenJson(newJson.object)
    }
    
    static func modifyAvatarUrl(url: String) {
        
        // ensure it's a NSURL
        guard let _ = NSURL(string: url) else { return }
        
        guard let json = IBBSLoginKey().tokenJson else { return }
        
        print(json)

        guard var dic = json.dictionaryObject else { return }
        
        // modified dic
        dic["avatar"] = url

        // re-convert to json
        let newJson = JSON(dic)
        
        // save
        saveTokenJson(newJson.object)
    }

    
//    static func modifyAvatarUrl(url: String) {
//        
//        // ensure it's a NSURL
//        guard let _ = NSURL(string: url) else { return }
//        
//        guard let json = IBBSLoginKey().tokenJson else { return }
//        
//        guard let data = try? json.rawData() else { return }
//
//        
//        // convert json to Dictionary
//        
//        guard let jsonObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) else { return }
//        
//        guard let dic = jsonObject.mutableCopy() as? NSMutableDictionary else { return }
//        
//        
//        // modified dic
//        
//        guard let _ = dic["avatar"] as? String else { return }
//        
//        dic.setObject(url, forKey: "avatar")
//        
//        
//        // re-convert to json
//        
//        let newJson = JSON(dic)
//        
//        saveTokenJson(newJson.object)
//    }
}


