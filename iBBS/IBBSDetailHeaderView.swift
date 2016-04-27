//
//  IBBSDetailHeaderView.swift
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

class IBBSDetailHeaderView: UIView {
    
    @IBOutlet weak var headerTitleLabel: UILabel! {
        didSet{
            headerTitleLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var avatarImageView: IBBSAvatarImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var content: UITextView!

    var nodeName: String?
    
    func loadData(json: JSON) {
        
        let model = IBBSTopicModel(json: json)
        
        avatarImageView.kf_setImageWithURL(model.avatarUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        
        avatarImageView.user = User(id: model.uid, name: model.username)

        nodeName              = model.board
        usernameLabel.text    = model.username
        headerTitleLabel.text = model.title
        timeLabel.text        = model.postTime
        content.ausAttributedText(model.content)
    }
    
}
