//
//  IBBSReplyCell.swift
//  iBBS
//
//  Created by Augus on 9/4/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON

class IBBSReplyCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: IBBSAvatarImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var replyContent: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .None
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadDataToCell(json: JSON) {
        let imageUrl = NSURL(string: json["avatar"].stringValue)
        avatarImageView.kf_setImageWithURL(imageUrl!, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        usernameLabel.text = json["username"].stringValue
        let data = json["comment_content"].stringValue
        DEBUGLog(data)

        replyContent.ausAttributedText(data)
        replyContent.ausReturnFrameSizeAfterResizingTextView()
    }
    
}
