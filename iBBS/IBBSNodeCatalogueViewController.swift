//
//  NodesViewController.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//
//  http://iAugus.com
//  https://github.com/iAugux
//
//  Copyright © 2015 iAugus. All rights reserved.
//


import UIKit
import SwiftyJSON

class IBBSNodeCatalogueViewController: UITableViewController {
    
    static let sharedInstance = IBBSNodeCatalogueViewController()
    
    struct MainStoryboard {
        static let nodeCellIdentifier = "nodesCell"
        static let nodeVCIdentifier = "iBBSNodeViewController"
        static let nodeToMainVCSegueIdentifier = "nodeToMainVC"
    }
    
    var nodesArray: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureNodesInfo()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView(){
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(IBBSNodesCell.classForCoder() , forCellReuseIdentifier: MainStoryboard.nodeCellIdentifier)
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
//        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
        //        tableView.scrollsToTop = false
        
    }
    
    func sendRequest() {
        APIClient.sharedInstance.getNodes({ (json) -> Void in
            if json.type == Type.Array {
                self.nodesArray = json.arrayValue
                print(json.arrayValue)
                self.tableView?.reloadData()
                IBBSContext.sharedInstance.saveNodes(json.object)
            }
            }) { (error) -> Void in
        }
    }
    
    
    func configureNodesInfo(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let nodes = IBBSContext.sharedInstance.getNodes()
            dispatch_async(dispatch_get_main_queue(), {
                if let json = nodes {
                    self.nodesArray = json.arrayValue
                    self.tableView.reloadData()
                } else {
                    self.sendRequest()
                }
            })
        })
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nodesArray != nil {
            return nodesArray!.count
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.nodeCellIdentifier) as? IBBSNodesCell {
            if let array = self.nodesArray {
                let json = array[indexPath.row]
                cell.textLabel?.text = json["name"].stringValue
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if let array = self.nodesArray {
            let json = array[indexPath.row]
            //            print(json)
            if let vc = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.nodeVCIdentifier) as? IBBSNodeViewController{
                vc.nodeJSON = json
                self.navigationController?.pushViewController(vc , animated: true)
                //
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
