//
//  NodesViewController.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//  Copyright © 2015 iAugus. All rights reserved.
//


import UIKit
import SwiftyJSON

class IBBSNodeCatalogueViewController: UITableViewController {
    struct MainStoryboard {
        static let nodeCellIdentifier = "nodesCell"
        static let mainVCIdentifier = "iBBSViewController"
        static let nodeToMainVCSegueIdentifier = "nodeToMainVC"
    }
    
    var nodesArray: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureNodesInfo()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView(){
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(NodesCell.classForCoder() , forCellReuseIdentifier: MainStoryboard.nodeCellIdentifier)
        
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
        tableView.backgroundColor = UIColor.clearColor()
        //        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        //        self.clearsSelectionOnViewWillAppear = false
        
        //        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
        
        
    }
    
    func sendRequest() {
        APIClient.sharedInstance.getNodes({ (json) -> Void in
            if json.type == Type.Array {
                self.nodesArray = json.arrayValue
                self.tableView?.reloadData()
                
                NodesContext.sharedInstance.saveNodes(json.object)
            }
            }) { (error) -> Void in
        }
    }
    
    func configureNodesInfo(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let nodes = NodesContext.sharedInstance.getNodes()
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
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.nodeCellIdentifier) as? NodesCell {
            if let array = self.nodesArray {
                let json = array[indexPath.row]
                cell.textLabel?.text = json["name"].stringValue
            }
            //            cell.nav = self.navigationController
            cell.backgroundColor = UIColor.redColor()
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if let array = self.nodesArray {
            let json = array[indexPath.row]
            //            print(json)
            if let destinationVC = IBBSViewController() ?? nil{
                
//                destinationVC.nodeJSON = json
                
                //                print(json["name"])
                sideMenuController()?.dismissViewOpen()
                sideMenuController()?.setContentViewController(destinationVC)
                
            }
        }
        
        //        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
