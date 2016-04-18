//
//  IBBSNodesCollectionViewCell.swift
//  iBBS
//
//  Created by Augus on 10/6/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSNodesCollectionViewCell: UICollectionViewCell {
    
    var customBackgroundView: IBBSCustomSelectedBackgroundView!

    @IBOutlet var infoLabel: UILabel! {
        didSet{
            infoLabel.text = nil
//            infoLabel.textColor = CUSTOM_THEME_COLOR
        }
    }
    
    @IBOutlet var imageView: UIImageView! {
        didSet{
            imageView.backgroundColor = CUSTOM_THEME_COLOR.lighterColor(0.75)
            imageView.layer.cornerRadius = 7.0
//            imageView.layer.borderWidth = 1
//            imageView.layer.borderColor = CUSTOM_THEME_COLOR.darkerColor(0.9).CGColor
            imageView.layer.shadowColor = CUSTOM_THEME_COLOR.darkerColor(0.9).CGColor
            imageView.layer.shadowOffset = CGSizeMake(1, 1)
            imageView.layer.shadowOpacity = 0.5
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customBackgroundView = IBBSCustomSelectedBackgroundView()
        selectedBackgroundView = customBackgroundView
        
    }
    
}
