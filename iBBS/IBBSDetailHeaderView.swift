//
//  IBBSDetailHeaderView.swift
//  iBBS
//
//  Created by Augus on 9/4/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var content: UILabel!{
        didSet{
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
