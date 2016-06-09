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
    
    var commentId: Int?
    
    @IBOutlet weak var avatarImageView: IBBSAvatarImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var trashButton: UIButton! {
        didSet {
            let image = UIImage(named: "trash")?.imageWithRenderingMode(.AlwaysTemplate)
            trashButton.setImage(image, forState: .Normal)
            trashButton.tintColor = UIColor.redColor()
            trashButton.addTarget(self, action: #selector(trashButtonDidTap), forControlEvents: .TouchUpInside)
        }
    }
    
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
        
        let key = IBBSLoginKey()
        guard key.isValid else { return }
        
        let isAdmin = key.isAdmin
        trashButton.hidden = !isAdmin
        trashButton.userInteractionEnabled = isAdmin
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadDataToCell(json: JSON) {
        
        let model = IBBSReplyMessageModel(json: json)
        
        commentId = model.id
        
        avatarImageView.kf_setImageWithURL(model.avatarUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        
        avatarImageView.user = User(id: model.uid, name: model.username)
        
        usernameLabel.text = model.username

        replyContent.ausAttributedText(model.content)
        replyContent.ausReturnFrameSizeAfterResizingTextView()
    }
    
    @objc private func trashButtonDidTap() {
        
        let alertController = UIAlertController(title: DELETE_THIS_COMMENT, message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: DELETE, style: .Destructive) { (_) in
            self.deleteComment()
        }
        
        let cancelAction = UIAlertAction(title: BUTTON_CANCEL, style: .Cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        parentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func deleteComment() {
        
        guard let id = commentId else { return }
        
        let key = IBBSLoginKey()
        
        guard key.isValid && key.isAdmin else { return }
        
        APIClient.defaultClient.deleteComment(key.uid, token: key.token, commentId: id, success: { (json) in
            
            let model = IBBSModel(json: json)
            
            if model.success {
                IBBSToast.make(model.message, delay: 0, interval: 3)
            } else {
                IBBSToast.make(model.message, delay: 0, interval: 5)
            }
            
        }) { (error) in
            IBBSToast.make(DELETE_FAILED_TRY_AGAIN, delay: 0, interval: 5)
        }
    }
}
