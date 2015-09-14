//
//  IBBSViewController.swift
//  iBBS
//
//  Created by Augus on 9/2/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit
import SwiftyJSON


class IBBSViewController: IBBSBaseViewController {
    
    var nodeJSON: JSON?
    
    struct MainStoryboard {
        struct CellIdentifiers {
            static let iBBSTableViewCell = "iBBSTableViewCell"
        }
        struct NibNames {
            static let iBBSTableViewCellNibName = "IBBSTableViewCell"
        }
        struct VCIdentifiers {
            static let mainDetailVC = "mainDetailViewController"
        }
    }
    
    @IBAction func tapToReload(sender: AnyObject) {
        //        tableView.reloadData()
        //        print("###########")
        //        print(datasource)
        //        print("###########")
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        self.configureView()
        
        self.refreshing = true
        self.sendRequest()
        
        
    }
    
    
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        //        self.navigationController?.setNavigationBarHidden(true , animated: true)
        
    }
    
    
    
    
    func sendRequest() {
        if let node = self.nodeJSON {
            self.refreshing = true
            APIClient.sharedInstance.getLatestTopics(node["id"].stringValue, success: { (json) -> Void in
                self.refreshing = false
                if json.type == Type.Array {
                    self.datasource = json.arrayValue
                    //                    self.tableView?.reloadData()
                    //                    self.refreshControl?.endRefreshing()
                    
                }
                }, failure: { (error) -> Void in
                    self.refreshing = false
            })
        } else {
            self.refreshing = true
            APIClient.sharedInstance.getLatestTopics({ (json) -> Void in
                self.refreshing = false
                if json.type == Type.Array {
                    self.datasource = json.arrayValue
                    //                    self.tableView?.reloadData()
                    //                    self.refreshControl?.endRefreshing()
                    
                }
                }, failure: { (error) -> Void in
                    self.refreshing = false
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
        
        /**
        important: if present NavigationController's property of interactivePopGestureRecognizer is enable, we must set it to disable,
        otherwise if we call UIScreenEdgePanGestureRecognizer on present ViewController it will crash.
        */
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
                self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    func configureView(){
        self.navigationController?.navigationBarHidden = false
        //        self.navigationController?.hidesBarsOnSwipe = true
        
        if let node = self.nodeJSON {
            self.title = node["title"].stringValue
        }else {
            self.title = "iBBS"
        }
    }
    
    func configureTableView(){
        tableView.registerNib(UINib(nibName: MainStoryboard.NibNames.iBBSTableViewCellNibName, bundle: nil ), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.iBBSTableViewCell)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            //            print(datasource)
            
            return datasource.count
            
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.iBBSTableViewCell) as? IBBSTableViewCell {
            let json = self.datasource[indexPath.row]
            print("****************")
            print(json)
            print("****************")
            print("****************")
            
            cell.loadDataToCell(json)
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    // MARK: - table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let json = self.datasource[indexPath.row]
        let vc = IBBSDetailViewController()
        vc.json = json
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // MARK: - refresh
    func refreshData(){
        
        //        self.sendRequest()
        // be sure to stop refreshing while there is an error with network or something else
        let refreshInSeconds = 5.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            //            self.tableView.reloadData()
            
            self.gearRefreshControl.endRefreshing()
        }
        
    }
    func onPullToFresh() {
        self.sendRequest()
    }
    
}
