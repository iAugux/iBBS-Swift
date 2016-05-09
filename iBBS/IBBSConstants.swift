//
//  IBBSConstants.swift
//  iBBS
//
//  Created by Augus on 9/16/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit


let kThemeDidChangeNotification                    = "kThemeDidChangeNotification"
let kShouldHideCornerActionButton                  = "kShouldHideCornerActionButton"
let kShouldShowCornerActionButton                  = "kShouldShowCornerActionButton"
let kShouldReloadDataAfterPosting                  = "kShouldReloadDataAfterPosting"
let kJustLoggedinNotification                      = "kJustLoggedinNotification"


var SHOULD_HIDE_NAVIGATIONBAR                      = false

let BLUR_VIEW_ALPHA_OF_BG_IMAGE: CGFloat           = 0.70

let isIphone3_5Inch: Bool                          = UIScreen.mainScreen().bounds.size.height == 480 ? true : false

let HEADER_TITLE_FONT_SIZE: CGFloat                = 17
let HEADER_CONTENT_FONT_SIZE: CGFloat              = 15.0

let TITLE_FOR_HEADER_IN_SECTION_FONT_SIZE: CGFloat = 15.0

let TIME_OF_TOAST_OF_REGISTER_SUCCESS: Double      = 3.0
let TIME_OF_TOAST_OF_REPLY_SUCCESS: Double         = 1.0
let TIME_OF_TOAST_OF_POST_SUCCESS: Double          = 3.5
let TIME_OF_TOAST_OF_POST_FAILED: Double           = 3.0
let TIME_OF_TOAST_OF_COMMENT_SUCCESS: Double       = 3.5
let TIME_OF_TOAST_OF_COMMENT_FAILED: Double        = 3
let TIME_OF_TOAST_OF_TOKEN_ILLEGAL: Double         = 1.0
let TIME_OF_TOAST_OF_SERVER_ERROR: Double          = 3.0
let TIME_OF_TOAST_OF_NO_MORE_DATA: Double          = 0.8

let SWIPE_LEFT_TO_CANCEL_RIGHT_TO_CONTINUE         = true



let AVATAR_PLACEHOLDER_IMAGE = UIImage(named: "avatar_placeholder")


@objc class ConstantsForObjc: NSObject {
    class var customThemeColorForObjc: UIColor {
        return CUSTOM_THEME_COLOR
    }
    
}