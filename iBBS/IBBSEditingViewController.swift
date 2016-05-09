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


let nodeID = "board"
let articleTitle = "title"

var contentsArrayOfPostArticle: NSMutableDictionary!

class IBBSEditingViewController: UIViewController, UITextViewDelegate {
    
    var segueId: String!
    var nodeId: Int!
    
    @IBOutlet var avatarImageView: IBBSAvatarImageView! {
        didSet{
            avatarImageView.antiOffScreenRendering = false
            
            avatarImageView.backgroundColor = CUSTOM_THEME_COLOR.darkerColor(0.75)
            IBBSContext.configureCurrentUserAvatar(avatarImageView)
        }
    }
    
    @IBOutlet var nodesPickerView: UIPickerView! {
        didSet{
            nodesPickerView.showsSelectionIndicator = false
        }
    }
    
    @IBOutlet var contentTextView: UITextView! {
        didSet{
            contentTextView.layer.cornerRadius = 4.0
            contentTextView.backgroundColor = CUSTOM_THEME_COLOR.darkerColor(0.75).colorWithAlphaComponent(0.35)
        }
    }
    
    private var node: JSON?
    private let postControllerID = "iBBSPostViewController"
    private var defaultSelectedRow: Int!
    private var blurView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        node = IBBSContext.getNodes()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self , action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: BUTTON_NEXT, style: .Plain, target: self, action: #selector(okAction(_:)))
        
        view.backgroundColor = UIColor(patternImage: BACKGROUNDER_IMAGE!)
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.alpha = BLUR_VIEW_ALPHA_OF_BG_IMAGE
        view.insertSubview(blurView, atIndex: 0)
        blurView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        }
  
        configureDefaultSelectedRow()
        
        nodesPickerView.delegate = self
        nodesPickerView.dataSource = self
        nodesPickerView.selectRow(defaultSelectedRow, inComponent: 0, animated: true)
        
        contentTextView.delegate = self
       
        contentsArrayOfPostArticle = NSMutableDictionary()
        
        // set default node ID
        contentsArrayOfPostArticle.setObject(defaultSelectedRow + 1, forKey: nodeID)
 
        contentTextView.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = CUSTOM_THEME_COLOR
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CUSTOM_THEME_COLOR]

        navigationController?.navigationBar.translucent = true
    }
    
    private func configureDefaultSelectedRow() {
        
        if segueId == postSegue {
            // IBBSViewController called me
            defaultSelectedRow = 0
        } else {
            // IBBSNodeViewController called me
            
            guard nodeId != nil else {
                defaultSelectedRow = 0
                return
            }
            
            defaultSelectedRow = nodeId - 1
        }
    }
    
    @objc private func cancelAction(){
        // close keyboard first
        contentTextView.resignFirstResponder()
        
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    @IBAction func okAction(sender: AnyObject) {
       
        guard let title = contentTextView.text else { return }
        
        contentsArrayOfPostArticle.setObject(title, forKey: articleTitle)
        
        if let title = contentsArrayOfPostArticle.valueForKey(articleTitle) as? String {
            
            let str = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

            if str.isEmpty {
                
                let alertController = UIAlertController(title: "", message: YOU_HAVENOT_WROTE_ANYTHING, preferredStyle: .Alert)
                let action = UIAlertAction(title: GOT_IT, style: .Cancel) { (_) -> Void in
                    self.contentTextView.becomeFirstResponder()
                }
                
                alertController.addAction(action)
                presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        guard let vc = UIStoryboard.Main.instantiateViewControllerWithIdentifier(String(IBBSPostViewController)) as? IBBSPostViewController else { return }
        
        navigationController?.pushViewController(vc , animated: true)
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


// MARK: - UIPickerViewDataSource

extension IBBSEditingViewController: UIPickerViewDataSource {
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return node?.count ?? 0
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        guard let node = node?.arrayValue[row] else { return nil }
        
        return node["name"].stringValue
    }
}


// MARK: - UIPickerViewDelegate

extension IBBSEditingViewController: UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let node = node?.arrayValue[row] else { return }
        
        let nodeId = node["id"].intValue
                
        // save node ID to array
        contentsArrayOfPostArticle.setObject(nodeId, forKey: nodeID)
    }
}