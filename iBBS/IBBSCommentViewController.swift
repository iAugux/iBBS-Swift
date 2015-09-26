//
//  IBBSCommentViewController.swift
//  iBBS
//
//  Created by Augus on 9/16/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSCommentViewController: ZSSRichTextEditor {

    var post_id = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Send"), style: .Plain, target: self, action: "sendAction")

    }

    func sendAction(){
        let content = getHTML()
        let loginData = IBBSContext.sharedInstance.getLoginData()
        let userID = loginData?["uid"].stringValue
        let token = loginData?["token"].stringValue

        APIClient.sharedInstance.comment(userID! , postID: post_id, content: content, token: token!, success: { (json ) -> Void in
            print(json)
            self.navigationController?.popViewControllerAnimated(true)
            }) { (error ) -> Void in
                print(error)
                self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)

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
