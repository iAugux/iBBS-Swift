//
//  IBBSThemes.swift
//  iBBS
//
//  Created by Augus on 10/7/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit


let kCurrentTheme = "kCurrentTheme"
var CUSTOM_THEME_COLOR = themeColorArray[2]
var BACKGROUNDER_IMAGE = UIImage(named: "bg_image_yellow")

public enum IBBSThemes: Int {
    case DefaultTheme
    case RedTheme
    case GreenTheme
    case YellowTheme
    case PurpleTheme
    case PinkTheme
    case BlackTheme
    
    public func setTheme() {
        switch self {
        case .DefaultTheme:
            CUSTOM_THEME_COLOR = themeColorArray[0]
            BACKGROUNDER_IMAGE = UIImage(named: "bg_image_blue")
            
        case .RedTheme:
            CUSTOM_THEME_COLOR = themeColorArray[1]
            BACKGROUNDER_IMAGE = UIImage(named: "bg_image_red")
            
        case .GreenTheme:
            CUSTOM_THEME_COLOR = themeColorArray[2]
            BACKGROUNDER_IMAGE = UIImage(named: "bg_image_green")
            
        case .YellowTheme:
            CUSTOM_THEME_COLOR = themeColorArray[3]
            BACKGROUNDER_IMAGE = UIImage(named: "bg_image_yellow")
            
        case .PurpleTheme:
            CUSTOM_THEME_COLOR = themeColorArray[4]
            BACKGROUNDER_IMAGE = UIImage(named: "bg_image_purple")
            
        case .PinkTheme:
            CUSTOM_THEME_COLOR = themeColorArray[5]
            BACKGROUNDER_IMAGE = UIImage(named: "bg_image_pink")
            
        case .BlackTheme:
            CUSTOM_THEME_COLOR = themeColorArray[6]
            BACKGROUNDER_IMAGE = UIImage(named: "bg_image_black")
            
        }
    }
    
    
}

public let themeColorArray = [
    UIColor(red:0, green:0.57, blue:1, alpha:1),
    UIColor.redColor(),
    UIColor(red:0.27, green:0.75, blue:0.76, alpha:1),
    UIColor(red:1, green:0.827, blue:0, alpha:1),
    UIColor.purpleColor(),
    UIColor(red:0.98, green:0.31, blue:0.73, alpha:1),
    UIColor(red:0.38, green:0.39, blue:0.4, alpha:1)
]

