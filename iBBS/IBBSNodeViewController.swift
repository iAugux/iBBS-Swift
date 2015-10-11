//
//  IBBSNodeViewController.swift
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


class IBBSNodeViewController: IBBSBaseViewController, UIGestureRecognizerDelegate {
    
    var nodeJSON: JSON?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pullUpToLoadmore()
        self.configureTableView()
        self.configureView()
        self.configureGestureRecognizer()
        
//        self.refreshing = true
        self.sendRequest(page)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        self.navigationController?.hidesBarsOnSwipe = true
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        //        self.navigationController?.setNavigationBarHidden(true , animated: true)
        //        self.toggleSideMenuView()
        
    }

    
    func sendRequest(page: Int) {
        if let node = self.nodeJSON {
            APIClient.sharedInstance.getLatestTopics(node["id"].stringValue, page: self.page, success: { (json) -> Void in
                if json == nil && page != 1 {
                    UIApplication.topMostViewController()?.view?.makeToast(message: NO_MORE_DATA, duration: TIME_OF_TOAST_OF_NO_MORE_DATA, position: HRToastPositionCenter)
                }
                
                if json.type == Type.Array {
                    if page == 1{
                        self.datasource = json.arrayValue
                        
                    }else {
                        let appendArray = json.arrayValue
                        self.datasource? += appendArray
                        self.tableView.reloadData()
                        print(self.datasource)
                    }
                    
                }
                }, failure: { (error) -> Void in
                    print(error)
                    self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)

            })
        }
    }
    
    func configureView(){
        self.navigationController?.navigationBarHidden = false
        
        if let node = self.nodeJSON {
            self.title = node["title"].stringValue
        }else {
            self.title = "iBBS"
        }
    }
    
    func configureTableView(){
        tableView.registerNib(UINib(nibName: MainStoryboard.NibIdentifiers.iBBSNodeTableViewCellName, bundle: nil ), forCellReuseIdentifier: MainStoryboard.CellIdentifiers.iBBSNodeTableViewCell)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureGestureRecognizer(){
        let edgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "toggleSideMenu:")
        edgeGestureRecognizer.edges = UIRectEdge.Right
        self.view.addGestureRecognizer(edgeGestureRecognizer)
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
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.iBBSNodeTableViewCell) as? IBBSNodeTableViewCell {
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
//        if let destinationVC = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.VCIdentifiers.iBBSDetailVC) as? IBBSDetailViewController {
//            destinationVC.json = json
//            self.navigationController?.pushViewController(destinationVC, animated: true)
//        }
        let destinationVC = IBBSDetailViewController()
        destinationVC.json = json
        self.navigationController?.pushViewController(destinationVC, animated: true)
            
        
    }
    
   
    
}


extension IBBSNodeViewController {
    // MARK: - refresh
    func refreshData(){
        
        self.sendRequest(page)
        //         be sure to stop refreshing while there is an error with network or something else
        let refreshInSeconds = 1.3
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
            self.page = 1
            self.gearRefreshControl.endRefreshing()
        }
        
    }

    // MARK: - pull up to load more
    func pullUpToLoadmore(){
        self.tableView.addFooterWithCallback({
            print("pulling up")
            self.page += 1
            print(self.page)
            
            self.sendRequest(self.page)
            let delayInSeconds: Double = 1.0
            let delta = Int64(Double(NSEC_PER_SEC) * delayInSeconds)
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delta)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                //                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
            })
        })
    }

    
}
