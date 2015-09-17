
//  APIClient.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let APIRootURL = "http://yabbs.sinaapp.com/index.php/Home/Api/"
//let APIRootURL = "http://127.0.0.1/YABBS/index.php/Home/Api/"

class APIClient {
    
    static let sharedInstance = APIClient()
    
    func getJSONData(path: String, parameters: [String : AnyObject]?, success: (JSON) -> Void, failure: (NSError) -> Void) {
        Alamofire.request(.GET, APIRootURL + path, parameters: parameters)
            .responseSwiftyJSON { (request, response, json, error) in
                if let err = error {
                    failure(err)
                } else {
                    success(json)
                }
        }
    }

    func readMessage(uid: AnyObject, token: AnyObject, msgID: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": uid, "token": token, "msg_id": msgID]
        self.getJSONData("read_message", parameters: dict , success: success, failure: failure)
    }
    
    func getMessages(userID: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "token": token]
        self.getJSONData("messages", parameters: dict, success: success, failure: failure)
    }
    
    func post(userID: AnyObject, nodeID: AnyObject, content: AnyObject, title: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "board": nodeID, "content": content, "title": title, "token": token]
        self.getJSONData("create_post", parameters: dict, success: success, failure: failure)
    }
    
    func comment(userID: AnyObject, postID: AnyObject, content: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "post_id": postID, "content": content, "token": token]
        self.getJSONData("create_comment", parameters: dict, success: success, failure: failure)
    }
    
    func userLogin(userID: String, passwd: String, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["user": userID, "password": passwd]
        self.getJSONData("login", parameters: dict, success: success, failure: failure)
    }

    func getLatestTopics(success: (JSON) -> Void, failure: (NSError) -> Void) {
        self.getJSONData("latest", parameters: nil, success: success, failure: failure)
    }
    
    func getLatestTopics(nodeID: NSString, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["boardId": nodeID]
        self.getJSONData("posts", parameters: dict, success: success, failure: failure)
    }

    func getReplies(postID: NSString, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["postId": postID]
        self.getJSONData("comments", parameters: dict, success: success, failure: failure)
    }
    
    func getNodes(success: (JSON) -> Void, failure: (NSError) -> Void) {
        self.getJSONData("boards", parameters: nil, success: success, failure: failure)
    }
}