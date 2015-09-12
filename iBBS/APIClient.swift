
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