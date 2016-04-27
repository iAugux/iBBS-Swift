//
//  IBBSEditorBaseViewController.swift
//  iBBS
//
//  Created by Augus on 10/12/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSEditorBaseViewController: ZSSRichTextEditor {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldShowKeyboard = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: BUTTON_SEND, style: .Plain, target: self, action: #selector(sendAction))
        
        formatHTML = false
        
        // Set the base URL if you would like to use relative links, such as to images.
        baseURL = NSURL(string: "http://iAugus.com")
        
        // Set the toolbar item color
        toolbarItemTintColor = UIColor.blackColor()
        
        // Set the toolbar selected color
        toolbarItemSelectedTintColor = CUSTOM_THEME_COLOR
        
        // Choose which toolbar items to show
        //        enabledToolbarItems = [ZSSRichTextEditorToolbarBold, ZSSRichTextEditorToolbarH1, ZSSRichTextEditorToolbarParagraph]
        /**
        
        ZSSRichTextEditorToolbarBold
        ZSSRichTextEditorToolbarItalic
        ZSSRichTextEditorToolbarSubscript
        ZSSRichTextEditorToolbarSuperscript
        ZSSRichTextEditorToolbarStrikeThrough
        ZSSRichTextEditorToolbarUnderline
        ZSSRichTextEditorToolbarRemoveFormat
        ZSSRichTextEditorToolbarJustifyLeft
        ZSSRichTextEditorToolbarJustifyCenter
        ZSSRichTextEditorToolbarJustifyRight
        ZSSRichTextEditorToolbarJustifyFull
        ZSSRichTextEditorToolbarH1
        ZSSRichTextEditorToolbarH2
        ZSSRichTextEditorToolbarH3
        ZSSRichTextEditorToolbarH4
        ZSSRichTextEditorToolbarH5
        ZSSRichTextEditorToolbarH6
        ZSSRichTextEditorToolbarTextColor
        ZSSRichTextEditorToolbarBackgroundColor
        ZSSRichTextEditorToolbarUnorderedList
        ZSSRichTextEditorToolbarOrderedList
        ZSSRichTextEditorToolbarHorizontalRule
        ZSSRichTextEditorToolbarIndent
        ZSSRichTextEditorToolbarOutdent
        ZSSRichTextEditorToolbarInsertImage
        ZSSRichTextEditorToolbarInsertLink
        ZSSRichTextEditorToolbarRemoveLink
        ZSSRichTextEditorToolbarQuickLink
        ZSSRichTextEditorToolbarUndo
        ZSSRichTextEditorToolbarRedo
        ZSSRichTextEditorToolbarViewSource
        ZSSRichTextEditorToolbarParagraph
        ZSSRichTextEditorToolbarAll
        ZSSRichTextEditorToolbarNone

         */
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = CUSTOM_THEME_COLOR
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func showInsertURLAlternatePicker() {
        dismissAlertView()
        let picker = IBBSPickerViewController()
        picker.demoView = self
        let nav = UINavigationController()
        nav.navigationBar.translucent = false
        presentViewController(nav, animated: true, completion: nil)
    }
    
    override func showInsertImageAlternatePicker() {
        dismissAlertView()
        let picker = IBBSPickerViewController()
        picker.demoView = self
        picker.isInsertImagePicker = true
        let nav = UINavigationController()
        nav.navigationBar.translucent = false
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func exportHTML() {
        NSLog("%@", getHTML())
    }

    func sendAction() {}

}
