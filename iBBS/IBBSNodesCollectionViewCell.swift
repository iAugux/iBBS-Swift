//
//  IBBSNodesCollectionViewCell.swift
//  iBBS
//
//  Created by Augus on 10/6/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSNodesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var infoLabel: UILabel!{
        didSet{
            infoLabel.text = nil
//            infoLabel.textColor = CUSTOM_THEME_COLOR
        }
    }
    @IBOutlet var imageView: UIImageView!{
        didSet{
            imageView.backgroundColor = CUSTOM_THEME_COLOR
            imageView.layer.cornerRadius = 7.0
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let backgroundView = IBBSCustomSelectedBackgroundView()
        self.selectedBackgroundView = backgroundView
        

    }
    
    
}
