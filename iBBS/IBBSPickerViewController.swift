//
//  IBBSPickerViewController.swift
//  iBBS
//
//  Created by Augus on 9/15/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSPickerViewController: UIViewController {
    
    var textField: UITextField!
    var isInsertImagePicker: Bool!
    var demoView: IBBSEditorBaseViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Custom initialization
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Picker"
        view.backgroundColor = UIColor.redColor()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveURL))
        navigationItem.rightBarButtonItem = saveButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancel))
        
        textField = UITextField(frame: CGRectMake(20, 20, view.frame.size.width - 40, 40))
        textField.text = !isInsertImagePicker ? "http://www.apple.com" : "http://fineprintnyc.com/images/blog/history-of-apple-logo/apple-logo-2.jpg"
        textField.layer.borderColor = UIColor.grayColor().CGColor
        textField.layer.borderWidth = 0.5
        textField.clearButtonMode = UITextFieldViewMode.Always
        view.addSubview(textField)
    }
    
    @objc private func cancel() {
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    @objc private func saveURL() {
        dismissViewControllerAnimated(true , completion: nil)
        let vc = demoView
        if !isInsertImagePicker {
            vc.showInsertLinkDialogWithLink(textField.text, title: nil)
        } else {
            vc.showInsertLinkDialogWithLink(textField.text, title: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
