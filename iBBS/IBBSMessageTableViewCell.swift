//
//  IBBSMessageTableViewCell.swift
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
import SwiftyJSON


class IBBSMessageTableViewCell: UITableViewCell {
    
    @IBOutlet var avatarImageView: IBBSAvatarImageView!
    @IBOutlet var isMessageRead: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    
    var isRead: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    func loadDataToCell(json: JSON) {
        
        let model = IBBSMessageModel(json: json)
        
        avatarImageView.kf_setImageWithURL(model.avatarUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        
        timeLabel.text    = model.sendTime
        contentLabel.text = model.content
        isRead            = model.isRead
        
        isMessageRead.image = UIImage(named: "message_is_read_marker")
        isRead ? isMessageRead.changeImageColor(CUSTOM_THEME_COLOR.lighterColor(0.7)) : ()
        
        if !model.isAdministrator {
            avatarImageView.backgroundColor = UIColor.blackColor()
            avatarImageView.image = UIImage(named: "administrator")
            usernameLabel.text = "Admin"
            avatarImageView.user = User(id: model.senderUid, name: "Admin")
        } else {
            usernameLabel.text = model.sender
            avatarImageView.user = User(id: model.senderUid, name: model.sender)
        }
        
    }
    
    func changeColorForMessageMarker() {
        
    }
}
