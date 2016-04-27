//
//  NSString+Addtions.swift
//  iBBS
//
//  Created by Augus on 9/5/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

extension NSString {
    
    func ausCalculateSize(size: CGSize, font: UIFont) -> CGSize {
        var expectedLabelSize: CGSize = CGSizeZero
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let attributes: [String : AnyObject] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle.copy()]
        expectedLabelSize = self.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil).size
        return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height))
    }
    
    func ausTrimHtmlInWhitespaceAndNewlineCharacterSet() -> NSString {
        var str = self
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<div><br /></div>"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<div><br/></div>"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<br />"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<br/>"))
        //        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "&nbsp;"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return str
    }
    
}

extension String {
    func ausTrimHtmlInWhitespaceAndNewlineCharacterSet() -> String {
        var str = self
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<div><br /></div>"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<div><br/></div>"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<br />"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<br/>"))
//        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "&nbsp;"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return str
    }
    
    func ausTrimHtmlInNewlineCharacterSet() -> String {
        var str = self
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<br /><div><br /></div>"))
        return str
    }
}