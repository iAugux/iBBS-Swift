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
    
    @IBOutlet weak var avatarImageView: UIImageView!{
        didSet{
            avatarImageView.layer.cornerRadius = 15.0
            avatarImageView.clipsToBounds      = true
            avatarImageView.layer.borderWidth  = 0.3
            avatarImageView.layer.borderColor  = UIColor.blackColor().CGColor
            avatarImageView.backgroundColor    = UIColor.randomColor()
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var replyContent: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadDataToCell(json: JSON) {
        let imageUrl = NSURL(string: json["avatar"].stringValue)
        avatarImageView.kf_setImageWithURL(imageUrl!)
        //        avatarImageView.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "iAugus_500k"))
        usernameLabel.text = json["username"].stringValue
        let data = json["comment_content"].stringValue
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        print(data)
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

        replyContent.ausAttributedText(data)
        replyContent.ausReturnFrameSizeAfterResizingTextView()
    }
    
}
