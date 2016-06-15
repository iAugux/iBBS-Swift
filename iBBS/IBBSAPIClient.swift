
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


let APIRootURL = "http://iaugusbbs.applinzi.com/index.php/Home/Api/"

//let APIRootURL = "http://192.168.1.100/YABBS/index.php/Home/Api/"
//let APIRootURL = "http://127.0.0.1/YABBS/index.php/Home/Api/"


class APIClient {
    
    static let defaultClient = APIClient()
    
    typealias Success = (JSON) -> ()
    typealias Failure = (NSError) -> ()
    
    func getJSONData(path: String, parameters: [String : AnyObject]?, success: Success, failure: Failure) {
        
        Alamofire.request(.GET, APIRootURL + path, parameters: parameters).responseSwiftyJSON { (response) in
            
            switch response.result {
            case .Success(let json):
                success(json)
            case .Failure(let error):
                failure(error)
            }
        }
    }
    
    func postJSONData(path: String, parameters: [String : AnyObject]?, success: Success, failure: Failure) {
        
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
    
    func readMessage(uid: AnyObject, token: AnyObject, msgID: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "token": token, "msg_id": msgID]
        getJSONData("read_message", parameters: dict , success: success, failure: failure)
    }
    
    func getMessages(userID: AnyObject, token: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": userID, "token": token]
        getJSONData("messages", parameters: dict, success: success, failure: failure)
    }
    
    func sendMessage(uid: AnyObject, token: AnyObject, receiver_uid: AnyObject, title: AnyObject, content: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "send_to": receiver_uid, "title": title, "content": content, "token": token]
        postJSONData("send_message", parameters: dict, success: success, failure: failure)
    }
    
    /**
     - parameter title:  title can be nil
     
     */
    func replyMessage(uid: AnyObject, token: AnyObject, receiver_uid: AnyObject, title: AnyObject? = nil, content: AnyObject, success: Success, failure: Failure) {
        var dict = [String: AnyObject]()
        if title == nil {
            dict = ["uid": uid, "send_to": receiver_uid, "content": content, "token": token]
        } else {
            dict = ["uid": uid, "send_to": receiver_uid, "title": title!, "content": content, "token": token]
        }
        postJSONData("reply_message", parameters: dict, success: success, failure: failure)
    }
    
    
    // MARK: - Post & Comment
    
    func post(userID: AnyObject, nodeID: AnyObject, content: AnyObject, title: AnyObject, token: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": userID, "board": nodeID, "content": content, "title": title, "token": token]
        postJSONData("create_post", parameters: dict, success: success, failure: failure)
    }
    
    func comment(userID: AnyObject, postID: AnyObject, content: AnyObject, token: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": userID, "post_id": postID, "content": content, "token": token]
        postJSONData("create_comment", parameters: dict, success: success, failure: failure)
    }
    
    
    // MARK: - Register & Login
    
    func userRegister(email: AnyObject, username: AnyObject, passwd: AnyObject, success: Success, failure: Failure) {
        let dict = ["email": email, "username": username, "password": passwd]
        postJSONData("register", parameters: dict, success: success, failure: failure)
    }
    
    func userLogin(username: AnyObject, passwd: AnyObject, success: Success, failure: Failure) {
        let dict = ["user": username, "password": passwd]
        postJSONData("login", parameters: dict, success: success, failure: failure)
    }
    
    
    // MARK: - Get Topics & Replies & Nodes
    
    func getLatestTopics(page: AnyObject, success: Success, failure: Failure) {
        let param = ["page": page]
        getJSONData("latest", parameters: param, success: success, failure: failure)
    }
    
    func getLatestTopics(nodeID: AnyObject, page: AnyObject, success: Success, failure: Failure) {
        let dict = ["boardId": nodeID, "page": page]
        getJSONData("posts", parameters: dict, success: success, failure: failure)
    }
    
    func getUserTopics(userId: AnyObject, page: AnyObject, suceess: Success, failure: Failure) {
        let dict = ["uid": userId, "page": page]
        getJSONData("user_posts", parameters: dict, success: suceess, failure: failure)
    }
    
    func getReplies(postID: AnyObject, page: AnyObject, success: Success, failure: Failure) {
        let dict = ["postId": postID, "page": page]
        getJSONData("comments", parameters: dict, success: success, failure: failure)
    }
    
    func getNodes(success: Success, failure: Failure) {
        getJSONData("boards", parameters: nil, success: success, failure: failure)
    }
    
    
    // MARK: - Favorites
    
    func getFavoriteTopics(uid: AnyObject, token: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "token": token]
        getJSONData("favorite_posts", parameters: dict, success: success, failure: failure)
    }
    
    func favorite(uid: AnyObject, token: AnyObject, postId: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "token": token, "post_id": postId]
        getJSONData("favorite", parameters: dict, success: success, failure: failure)
    }
    
    func unFavorite(uid: AnyObject, token: AnyObject, postId: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "token": token, "post_id": postId]
        getJSONData("unfavorite", parameters: dict, success: success, failure: failure)
    }
    
    
    // MARK: - Delete (Admin)
    
    func deleteTopic(uid: AnyObject, token: AnyObject, postId: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "token": token, "post_id": postId]
        getJSONData("delete_post", parameters: dict, success: success, failure: failure)
    }
    
    func deleteComment(uid: AnyObject, token: AnyObject, commentId: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "token": token, "comment_id": commentId]
        getJSONData("delete_comment", parameters: dict, success: success, failure: failure)
    }
    
}


// MARK: - Settings

extension APIClient {
    
    func changePassword(username: AnyObject, oldPassword: AnyObject, newPassword: AnyObject, success: Success, failure: Failure) {
        let dict = ["username": username, "old_password": oldPassword, "new_password": newPassword]
        postJSONData("change_password", parameters: dict, success: success, failure: failure)
    }
    
    func changeAvatar(uid: AnyObject, token: AnyObject, url: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "token": token, "url": url]
        postJSONData("change_avatar", parameters: dict, success: success, failure: failure)
    }
    
    func changeUsername(uid: AnyObject, username: AnyObject, old_username: AnyObject, token: AnyObject, success: Success, failure: Failure) {
        let dict = ["uid": uid, "username": username, "old_username": old_username, "token": token]
        postJSONData("change_username", parameters: dict, success: success, failure: failure)
    }
}