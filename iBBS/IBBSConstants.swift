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



var SHOULD_HIDE_NAVIGATIONBAR = false
let CUSTOM_THEME_COLOR =  UIColor(red:1, green:0.827, blue:0, alpha:1)
let BACKGROUNDER_IMAGE = UIImage(named: "bg_image_yellow")
let BLUR_VIEW_ALPHA_OF_BG_IMAGE: CGFloat = 0.70

let isIphone3_5Inch: Bool = UIScreen.mainScreen().bounds.size.height == 480 ? true : false

let HEADER_TITLE_FONT_SIZE: CGFloat = 17
let HEADER_CONTENT_FONT_SIZE: CGFloat = 15.0

let TITLE_FOR_HEADER_IN_SECTION_FONT_SIZE: CGFloat = 15.0


let TIME_OF_TOAST_OF_SERVER_ERROR: Double = 4
let TIME_OF_TOAST_OF_NO_MORE_DATA: Double = 0.8

let SWIPE_LEFT_TO_CANCEL_RIGHT_TO_CONTINUE = true


let AVATAR_PLACEHOLDER_IMAGE = UIImage(named: "avatar_placeholder")

class ThemeColorAndBackgrounderImage {
    let dic = [
        UIColor.redColor(): UIImage(named: "bg_image_green")
    ]
    
}

let d = NSMutableDictionary()
let THEMES: NSMutableDictionary = [
    UIColor.redColor(): UIImage(named: "bg_image_red")!,
    UIColor.greenColor(): UIImage(named: "bg_image_green")!,
    UIColor.yellowColor(): UIImage(named: "bg_image_yellow")!,
//    UIColor.blueColor(): UIImage(named: "bg_image_blue")!,
//    UIColor.purpleColor(): UIImage(named: "bg_image_purple")!
]


@objc class  ConstantsForObjc: NSObject {
    class func customThemeColorForObjc() -> UIColor {
        return CUSTOM_THEME_COLOR
    }
    
}