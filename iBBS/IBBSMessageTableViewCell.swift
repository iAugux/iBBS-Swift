//
//  IBBSMessageTableViewCell.swift
//  iBBS
//
//  Created by Augus on 9/16/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON


class IBBSMessageTableViewCell: UITableViewCell {
    @IBOutlet var avatarImageView: UIImageView!{
        didSet{
            avatarImageView.clipsToBounds       = true
            avatarImageView.layer.borderWidth   = 0.3
            avatarImageView.layer.borderColor   = UIColor.blackColor().CGColor
            avatarImageView.layer.cornerRadius  = 18.0
            avatarImageView.backgroundColor     = UIColor.randomColor()
        }
    }
    @IBOutlet var isMessageRead: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    var imagePath: UIBezierPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func loadDataToCell(json: JSON) {
        let imageUrl = NSURL(string: json["sender_avatar"].stringValue)
        avatarImageView.sd_setImageWithURL(imageUrl)
        timeLabel.text = json["send_time"].stringValue
        contentLabel.text = json["title"].stringValue
        usernameLabel.text = json["sender"].stringValue
        
        if let isRead = json["is_read"].intValue ?? nil {
            if isRead == 0 {
                self.isMessageRead.image = UIImage(named: "message_read_0")
            }else if isRead == 1{
                self.isMessageRead.image = UIImage(named: "message_read_1")
            }
        }
        
        if let isAdministrator = json["type"].intValue ?? nil {
            if isAdministrator == 1 {
                self.avatarImageView.backgroundColor = UIColor.blackColor()
                self.avatarImageView.image = UIImage(named: "Administrator")
            }
        }
        
    }
}
