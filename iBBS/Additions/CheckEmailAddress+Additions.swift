//
//  CheckEmailAddress+Additions.swift
//  iBBS
//
//  Created by Augus on 10/3/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import Foundation


extension NSString {
    func isValidEmail() -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
    
    func isValidPassword() -> Bool {
        let passwdRegex = "^([a-zA-Z0-9]|[*_ !^?#@%$&=+-]){4,16}$"
        let passwdTest = NSPredicate(format: "SELF MATCHES %@", passwdRegex)
        return passwdTest.evaluateWithObject(self)
    }
    
    
}