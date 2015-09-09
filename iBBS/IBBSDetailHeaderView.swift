//
//  IBBSDetailHeaderView.swift
//  iBBS
//
//  Created by Augus on 9/4/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class IBBSDetailHeaderView: UIView {
    @IBOutlet weak var headerTitleLabel: UILabel!{
        didSet{
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var content: UITextView!{
        didSet{
            self.content.text = ""
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

        
    func loadData(json: JSON){
        let avatarUrl = NSURL(string: json["avatar"].stringValue)
        avatarImageView?.sd_setImageWithURL(avatarUrl)
        usernameLabel?.text = json["username"].stringValue
        headerTitleLabel?.text = json["title"].stringValue
        timeLabel?.text = ""
        let data = json["post_content"].stringValue
        

        self.content.ausAttributedText(data)

//        dispatch_sync(dispatch_get_main_queue()) {
//            
//        }
//        print(data)
        
    }
}
