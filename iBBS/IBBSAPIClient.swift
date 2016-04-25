
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


let APIRootURL = "http://192.168.1.179/YABBS/index.php/Home/Api/"

//let APIRootURL = "http://192.168.1.100/YABBS/index.php/Home/Api/"
//let APIRootURL = "http://127.0.0.1/YABBS/index.php/Home/Api/"
//let APIRootURL = "http://obbs.sinaapp.com/index.php/Home/Api/"


class APIClient {
    
    static let sharedInstance = APIClient()
    
    func getJSONData(path: String, parameters: [String : AnyObject]?, success: (JSON) -> Void, failure: (NSError) -> Void) {
        
        Alamofire.request(.GET, APIRootURL + path, parameters: parameters).responseSwiftyJSON { (response) in
            
            switch response.result {
            case .Success(let json):
                success(json)
            case .Failure(let error):
                failure(error)
            }
        }
    }
    
    func postJSONData(path: String, parameters: [String : AnyObject]?, success: (JSON) -> Void, failure: (NSError) -> Void) {
        
        Alamofire.request(.GET, APIRootURL + path, parameters: parameters).responseSwiftyJSON { (response) in
            
            switch response.result {
            case .Success(let json):
                success(json)
            case .Failure(let error):
                failure(error)
            }
        }
    }
    
    
    // MARK: - Messages
    
    func readMessage(uid: AnyObject, token: AnyObject, msgID: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": uid, "token": token, "msg_id": msgID]
        getJSONData("read_message", parameters: dict , success: success, failure: failure)
    }
    
    func getMessages(userID: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "token": token]
        getJSONData("messages", parameters: dict, success: success, failure: failure)
    }
    
    func sendMessage(uid: AnyObject, token: AnyObject, receiver_uid: AnyObject, title: AnyObject, content: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": uid, "send_to": receiver_uid, "title": title, "content": content, "token": token]
        postJSONData("send_message", parameters: dict, success: success, failure: failure)
    }
    
    /**
     - parameter title:  title can be nil
     
     */
    func replyMessage(uid: AnyObject, token: AnyObject, receiver_uid: AnyObject, title: AnyObject? = nil, content: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        var dict = [String: AnyObject]()
        if title == nil {
            dict = ["uid": uid, "send_to": receiver_uid, "content": content, "token": token]
        } else {
            dict = ["uid": uid, "send_to": receiver_uid, "title": title!, "content": content, "token": token]
        }
        postJSONData("reply_message", parameters: dict, success: success, failure: failure)
    }
    
    
    // MARK: - Post & Comment
    
    func post(userID: AnyObject, nodeID: AnyObject, content: AnyObject, title: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "board": nodeID, "content": content, "title": title, "token": token]
        postJSONData("create_post", parameters: dict, success: success, failure: failure)
    }
    
    func comment(userID: AnyObject, postID: AnyObject, content: AnyObject, token: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["uid": userID, "post_id": postID, "content": content, "token": token]
        postJSONData("create_comment", parameters: dict, success: success, failure: failure)
    }
    
    
    // MARK: - Register  Login
    
    func userRegister(email: AnyObject, username: AnyObject, passwd: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["email": email, "username": username, "password": passwd]
        postJSONData("register", parameters: dict, success: success, failure: failure)
    }
    
    func userLogin(userID: AnyObject, passwd: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["user": userID, "password": passwd]
        getJSONData("login", parameters: dict, success: success, failure: failure)
    }
    
    
    // MARK: - Get Topics & Replies * Nodes
    
    func getLatestTopics(page: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let param = ["page": page]
        getJSONData("latest", parameters: param, success: success, failure: failure)
    }
    
    func getLatestTopics(nodeID: AnyObject, page: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["boardId": nodeID, "page": page]
        getJSONData("posts", parameters: dict, success: success, failure: failure)
    }
    
    func getReplies(postID: AnyObject, page: AnyObject, success: (JSON) -> Void, failure: (NSError) -> Void) {
        let dict = ["postId": postID, "page": page]
        getJSONData("comments", parameters: dict, success: success, failure: failure)
    }
    
    func getNodes(success: (JSON) -> Void, failure: (NSError) -> Void) {
        getJSONData("boards", parameters: nil, success: success, failure: failure)
    }
    
    
}