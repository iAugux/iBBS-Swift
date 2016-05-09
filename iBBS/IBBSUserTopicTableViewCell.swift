//
//  IBBSUserTopicTableViewCell.swift
//  iBBS
//
//  Created by Augus on 5/4/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON


class IBBSUserTopicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var nodeName: UILabel!
    @IBOutlet weak var postTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //        selectionStyle = UITableViewCellSelectionStyle.None
        
        // Initialization code
        //        backgroundColor = UIColor.clearColor()
        
        separatorInset = UIEdgeInsetsZero
        layoutMargins  = UIEdgeInsetsZero
        selectionStyle = .None
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadDataToCell(json: JSON) {
        
        let model = IBBSUserTopicModel(json: json)
        
        topicLabel.text = model.title
        nodeName.text   = model.board
        postTime.text   = model.postTime
    }

}