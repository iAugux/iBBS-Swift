//
//  IBBSCommentViewController.swift
//  iBBS
//
//  Created by Augus on 9/16/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSCommentViewController: ZSSRichTextEditor {

    var uid = String()
    var token = String()
    var post_id = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send"), style: .Plain, target: self, action: "sendAction")

    }

    func sendAction(){
        let content = getHTML()
        print(uid)
        print(token)
        print(post_id)
        print(content)
        APIClient.sharedInstance.comment(uid , postID: post_id, content: content, token: token, success: { (json ) -> Void in
            print(json)
            }) { (error ) -> Void in
                print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
