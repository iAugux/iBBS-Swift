//
//  IBBSContents.swift
//  iBBS
//
//  Created by Augus on 9/16/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//


let isIphone3_5Inch: Bool = UIScreen.mainScreen().bounds.size.height == 480 ? true : false

let storyboard = UIStoryboard(name: "Main", bundle: nil)

let kExpandedOffSet: CGFloat = 130.0

let HEADER_TITLE_FONT_SIZE: CGFloat = 17
let HEADER_CONTENT_FONT_SIZE: CGFloat = 15.0
//let HEADER_TITLE_LABEL_WIDTH: CGFloat = 296.0
//let HEADER_CONTENT_LABEL_WIDTH: CGFloat = 295.0

let TITLE_FOR_HEADER_IN_SECTION_FONT_SIZE: CGFloat = 15.0


let TIME_OF_TOAST_OF_SERVER_ERROR: Double = 4
let TIME_OF_TOAST_OF_NO_MORE_DATA: Double = 0.8

let SWIPE_LEFT_TO_CANCEL_RIGHT_TO_CONTINUE = true


let AVATAR_PLACEHOLDER_IMAGE = UIImage(named: "avatar_placeholder")