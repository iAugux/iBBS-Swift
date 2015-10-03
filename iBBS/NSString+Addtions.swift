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

import Foundation

extension NSString {
    
    func ausCalculateSize(size: CGSize, font: UIFont) -> CGSize {
        var expectedLabelSize: CGSize = CGSizeZero
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let attributes: [String : AnyObject] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle.copy()]
        expectedLabelSize = self.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil).size
        return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height))
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
    
    func ausTrimHtmlInWhitespaceAndNewlineCharacterSet() -> String {
        var str = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<div><br /></div>"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<br />"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "&nbsp;"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return str
    }
    
    
}

extension String {
    func ausTrimHtmlInWhitespaceAndNewlineCharacterSet() -> String {
        var str = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<div><br /></div>"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<br />"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "&nbsp;"))
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return str
    }
}