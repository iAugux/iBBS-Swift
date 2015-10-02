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
    var demoView: IBBSPostViewController!
    var demoViewForCommenting : IBBSCommentViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Custom initialization
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Picker"
        self.view.backgroundColor = UIColor.whiteColor()
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveURL")
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        
        self.textField = UITextField(frame: CGRectMake(20, 20, self.view.frame.size.width - 40, 40))
        self.textField.text = !self.isInsertImagePicker ? "http://www.apple.com" : "http://fineprintnyc.com/images/blog/history-of-apple-logo/apple-logo-2.jpg"
        self.textField.layer.borderColor = UIColor.grayColor().CGColor
        self.textField.layer.borderWidth = 0.5
        self.textField.clearButtonMode = UITextFieldViewMode.Always
        self.view.addSubview(self.textField)
        
    }
    
    func cancel(){
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    func saveURL(){
        self.dismissViewControllerAnimated(true , completion: nil)
        let vc = self.demoView
        if !self.isInsertImagePicker {
            vc.showInsertLinkDialogWithLink(self.textField.text, title: nil)
        }else{
            vc.showInsertLinkDialogWithLink(self.textField.text, title: nil)
        }
        
        
        let commentVC = self.demoViewForCommenting
        if !self.isInsertImagePicker {
            commentVC.showInsertLinkDialogWithLink(self.textField.text, title: nil)
        }else{
            commentVC.showInsertLinkDialogWithLink(self.textField.text, title: nil)
        }
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
