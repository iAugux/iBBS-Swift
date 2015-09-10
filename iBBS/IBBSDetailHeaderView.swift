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
            headerTitleLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView!{
        didSet{
            avatarImageView.layer.cornerRadius = 14.0
            avatarImageView.clipsToBounds      = true
            avatarImageView.layer.borderWidth  = 1.0
            avatarImageView.layer.borderColor  = UIColor.blackColor().CGColor
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var content: UITextView!

    var nodeName: String?
    
    func loadData(json: JSON){
        
        let avatarUrl = NSURL(string: json["avatar"].stringValue)
        avatarImageView?.sd_setImageWithURL(avatarUrl)
        usernameLabel?.text = json["username"].stringValue
        headerTitleLabel?.text = json["title"].stringValue
        timeLabel?.text = json["post_time"].stringValue
        let data = json["post_content"].stringValue
        self.content.ausAttributedText(data)
//        self.content.ausAutomanticResizeTextViewFrameSize()
        
        nodeName = json["board"].stringValue
    }
    
}
