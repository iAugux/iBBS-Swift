
//  APIClient.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//let APIRootURL = "http://127.0.0.1/YABBS/index.php/Home/Api/"
let APIRootURL = "http://obbs.sinaapp.com/index.php/Home/Api/"


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

    func postJSONData(path: String, parameters: [String : AnyObject]?, success: (JSON) -> Void, failure: (NSError) -> Void) {
        Alamofire.request(.POST, APIRootURL + path, parameters: parameters)
            .responseSwiftyJSON { (request, response, json, error) in
                if let err = error {
                    failure(err)
                } else {
                    success(json)
                }
        }
    }

    func isLogin(uid: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void){
        let param = ["uid": uid, "token": token]
        self.getJSONData("isLogin", parameters: param, success: success, failure: failure)
    }
    
    func readMessage(uid: AnyObject, token: AnyObject, msgID: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": uid, "token": token, "msg_id": msgID]
        self.getJSONData("read_message", parameters: dict , success: success, failure: failure)
    }
    
    func getMessages(userID: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "token": token]
        self.getJSONData("messages", parameters: dict, success: success, failure: failure)
    }
    
//    func replyMessage(uid: AnyObject, token: AnyObject, receiver_uid: AnyObject, content: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
//        let dict = ["uid": uid, "send_to": receiver_uid, "content": content, "token": token]
//        self.postJSONData("reply_message", parameters: dict, success: success, failure: failure)
//    }
    
    
    
    /**
    - parameter title:        when it's 'ReplyMessage', title can be nil

    */
    func sendOrReplyMessage(uid: AnyObject, token: AnyObject, receiver_uid: AnyObject, title: AnyObject?, content: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        var dict = [String: AnyObject]()
        if title == nil {
            dict = ["uid": uid, "send_to": receiver_uid, "content": content, "token": token]
        }else{
            dict = ["uid": uid, "send_to": receiver_uid, "title": title!, "content": content, "token": token]
        }
        self.postJSONData("send_message", parameters: dict, success: success, failure: failure)
    }
    
    func post(userID: AnyObject, nodeID: AnyObject, content: AnyObject, title: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "board": nodeID, "content": content, "title": title, "token": token]
        self.postJSONData("create_post", parameters: dict, success: success, failure: failure)
    }
    
    func comment(userID: AnyObject, postID: AnyObject, content: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "post_id": postID, "content": content, "token": token]
        self.postJSONData("create_comment", parameters: dict, success: success, failure: failure)
    }
    
    func userRegister(email: AnyObject, username: AnyObject, passwd: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["email": email, "username": username, "password": passwd]
        self.postJSONData("register", parameters: dict, success: success, failure: failure)
    }
    
    func userLogin(userID: AnyObject, passwd: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["user": userID, "password": passwd]
        self.getJSONData("login", parameters: dict, success: success, failure: failure)
    }

    func getLatestTopics(page: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let param = ["page": page]
        self.getJSONData("latest", parameters: param, success: success, failure: failure)
    }
    
    func getLatestTopics(nodeID: AnyObject, page: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["boardId": nodeID, "page": page]
        self.getJSONData("posts", parameters: dict, success: success, failure: failure)
    }

    func getReplies(postID: AnyObject, page: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["postId": postID, "page": page]
        self.getJSONData("comments", parameters: dict, success: success, failure: failure)
    }
    
    func getNodes(success: (JSON) -> Void, failure: (NSError) -> Void) {
        self.getJSONData("boards", parameters: nil, success: success, failure: failure)
    }
}