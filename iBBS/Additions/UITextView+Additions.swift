//
//  UITextView+Additions.swift
//  iBBS
//
//  Created by Augus on 9/8/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit


extension UITextView {
    
    /**
    Methods to allow using HTML code with CoreText
    
    */

    func ausAttributedText(data: String) {
                
        var formatedData = data.stringByDecodingHTMLEntities()
        formatedData = formatedData.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
        
        let text = try? NSAttributedString(data: formatedData.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
                                          options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                          documentAttributes: nil)
        
        self.attributedText = text
    }

    
    /**
    calculate size of UITextView
    
    :returns: CGSize
    */
    func ausReturnFrameSizeAfterResizingTextView() -> CGSize {
        let fixedWidth = self.frame.size.width
        self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = self.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        self.frame = newFrame
        return self.frame.size
    }
    
    
}


func ausTextViewSizeForAttributedText(text: String) -> CGSize {
    let calculationView = UITextView()
    calculationView.ausAttributedText(text)
    let size = calculationView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max))
    return size
}