//
//  IBBSEditingViewController.swift
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
import SwiftyJSON

var articleArray: NSMutableDictionary!

class IBBSEditingViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var avatarImageView: UIImageView!{
        didSet{
            avatarImageView.clipsToBounds       = true
            avatarImageView.layer.borderWidth   = 0.3
            avatarImageView.layer.borderColor   = UIColor.blackColor().CGColor
            avatarImageView.layer.cornerRadius  = 30.0
            avatarImageView.backgroundColor     = UIColor.randomColor()
            IBBSContext.sharedInstance.configureCurrentUserAvatar(avatarImageView)
        }
    }
    @IBOutlet var nodesPickerView: UIPickerView!{
        didSet{
            nodesPickerView.showsSelectionIndicator = false
        }
    }
    @IBOutlet var contentTextView: UITextView!{
        didSet{
            contentTextView.layer.cornerRadius = 8.0
        }
    }
    
    private let node: JSON? = IBBSContext.sharedInstance.getNodes()
    private let nodeID = "board"
    private let articleTitle = "title"
    private let postControllerID = "iBBSPostViewController"
    private var loginAlertController: UIAlertController!
    private let defaultSelectedRow = 2
    private var blurView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareForPosting()
        self.nodesPickerView.delegate = self
        self.nodesPickerView.dataSource = self
        self.nodesPickerView.selectRow(defaultSelectedRow, inComponent: 0, animated: true)
        self.contentTextView.delegate = self
        print("$$$$$$$$$$$$$$")

        print(IBBSContext.sharedInstance.getLoginData())
        print("$$$$$$$$$$$$$$")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self , action: "cancelAction")
        articleArray = NSMutableDictionary()
        // set default node ID
        articleArray.setValue(defaultSelectedRow + 1, forKey: nodeID)
        
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg_image")!)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = self.view.bounds
        self.view.insertSubview(blurView, atIndex: 0)
    }
    
    func cancelAction(){
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    @IBAction func okAction(sender: AnyObject) {
       
        let title = self.contentTextView.text
        articleArray.setValue(title, forKey: self.articleTitle)
        
        if let title = articleArray.valueForKey(self.articleTitle) as? String {
            let str = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as NSString
            if str.length == 0 {
                self.configureAlertController()
                return
            }
            
        }
        
        if let vc = storyboard?.instantiateViewControllerWithIdentifier(self.postControllerID) as? IBBSPostViewController {
            self.navigationController?.pushViewController(vc , animated: true)
        }
    }
    
    func prepareForPosting(){
        if !IBBSContext.sharedInstance.isLogin() {
            self.loginAlertController = UIAlertController()
            IBBSContext.sharedInstance.login(loginAlertController, presentingVC: self, completion: {
                IBBSContext.sharedInstance.configureCurrentUserAvatar(self.avatarImageView)
            })
        }
    }
    
    func configureAlertController() {
        let alertController = UIAlertController(title: "", message: "You haven't wrote anything!", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Got it", style: .Cancel) { (_) -> Void in
            self.contentTextView.becomeFirstResponder()
        }
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.contentTextView.resignFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let str = text as NSString
        if str.isEqual("\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension IBBSEditingViewController: UIPickerViewDataSource {
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let node = self.node {
            return node.count
        }else{
            return 0
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerID = self.nodesPickerView.selectedRowInComponent(0)
        print(pickerID)
        // save node ID to array
        articleArray.setDictionary([nodeID: pickerID])
    }
}

extension IBBSEditingViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        print(node)
        if let node = self.node {
            let node = node.arrayValue[row]
            let nodeName = node["name"].stringValue
            return nodeName
        }
        return ""
    }
    
}