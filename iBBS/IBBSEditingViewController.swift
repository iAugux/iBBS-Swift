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

var contentsArrayOfPostArticle: NSMutableDictionary!
var whoCalledEditingViewController: Int! = -1

class IBBSEditingViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var avatarImageView: IBBSAvatarImageView!{
        didSet{
           
            avatarImageView.backgroundColor = CUSTOM_THEME_COLOR.darkerColor(0.75)
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
            contentTextView.backgroundColor = CUSTOM_THEME_COLOR.darkerColor(0.75).colorWithAlphaComponent(0.35)
        }
    }
    
    private var node: JSON?
    private let nodeID = "board"
    private let articleTitle = "title"
    private let postControllerID = "iBBSPostViewController"
    private var defaultSelectedRow: Int!
    private var blurView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IBBSConfigureNodesInfo.sharedInstance.configureNodesInfo()
        node = IBBSContext.sharedInstance.getNodes()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self , action: "cancelAction")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: BUTTON_NEXT, style: .Plain, target: self, action: "okAction:")
        view.backgroundColor = UIColor(patternImage: BACKGROUNDER_IMAGE!)
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = view.frame
        blurView.alpha = BLUR_VIEW_ALPHA_OF_BG_IMAGE
        view.insertSubview(blurView, atIndex: 0)
  
        configureDefaultSelectedRow()
        nodesPickerView.delegate = self
        nodesPickerView.dataSource = self
        nodesPickerView.selectRow(defaultSelectedRow, inComponent: 0, animated: true)
        contentTextView.delegate = self
       
        contentsArrayOfPostArticle = NSMutableDictionary()
        // set default node ID
        contentsArrayOfPostArticle.setValue(defaultSelectedRow, forKey: nodeID)
 
        let delayInSeconds: Double = 0.7
        let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
        let popTime = dispatch_time(DISPATCH_TIME_NOW,delta)
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.contentTextView.becomeFirstResponder()
        })

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.translucent = true
        
//        navigationController?.navigationBar.backgroundColor = UIColor.redColor()
        navigationController?.navigationBar.tintColor = CUSTOM_THEME_COLOR
        //        navigationController?.navigationBar.barTintColor = UIColor.clearColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CUSTOM_THEME_COLOR]

        navigationController?.navigationBar.translucent = true

    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        blurView.frame = CGRectMake(0, 0, 750, 750)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        blurView.frame = view.frame
    }
    
    func configureDefaultSelectedRow() {
        if whoCalledEditingViewController == -1 { // IBBSViewController called me
            defaultSelectedRow = 2
        } else {
            defaultSelectedRow = whoCalledEditingViewController
        }
    }
    
    func cancelAction(){
        // close keyboard first
        contentTextView.resignFirstResponder()
        
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    @IBAction func okAction(sender: AnyObject) {
       
        let title = contentTextView.text
        contentsArrayOfPostArticle.setValue(title, forKey: articleTitle)
        
        if let title = contentsArrayOfPostArticle.valueForKey(articleTitle) as? String {
            let str = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if str.utf8.count == 0 {
                
                let alertController = UIAlertController(title: "", message: YOU_HAVENOT_WROTE_ANYTHING, preferredStyle: .Alert)
                let action = UIAlertAction(title: GOT_IT, style: .Cancel) { (_) -> Void in
                    self.contentTextView.becomeFirstResponder()
                }
                
                alertController.addAction(action)
                presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
            
        }
        
        if let vc = storyboard?.instantiateViewControllerWithIdentifier(postControllerID) as? IBBSPostViewController {
            navigationController?.pushViewController(vc , animated: true)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        contentTextView.resignFirstResponder()
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
        if let node = node {
            return node.count
        } else {
            return 0
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //        DEBUGLog(node)
        if let node = node {
            let node = node.arrayValue[row]
            let nodeName = node["name"].stringValue
            return nodeName
        }
        return ""
    }
    

}

extension IBBSEditingViewController: UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerID = nodesPickerView.selectedRowInComponent(0)
        DEBUGLog(pickerID)
        // save node ID to array
        contentsArrayOfPostArticle.setDictionary([nodeID: pickerID])
    }
}