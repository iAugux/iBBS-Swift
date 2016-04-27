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
    
    @IBOutlet weak var replyContent: UITextView! {
        didSet {
            replyContent.sizeToFit()
        }
    }
    
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
        
        let model = IBBSReplyMessageModel(json: json)
        
        avatarImageView.kf_setImageWithURL(model.avatarUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        
        avatarImageView.user = User(id: model.uid, name: model.username)
        
        usernameLabel.text = model.username

        replyContent.ausAttributedText(model.content)
        replyContent.ausReturnFrameSizeAfterResizingTextView()
    }
    
}
