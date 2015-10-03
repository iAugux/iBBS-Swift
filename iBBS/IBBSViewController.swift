//
//  IBBSViewController.swift
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


class IBBSViewController: IBBSBaseViewController {
    
    struct MainStoryboard {
        struct CellIdentifiers {
            static let iBBSTableViewCell = "iBBSTableViewCell"
        }
        struct NibNames {
            static let iBBSTableViewCellNibName = "IBBSTableViewCell"
        }
        struct VCIdentifiers {
            static let editVC = "iBBSEditingViewController"
            static let detailVC = "iBBSDetailViewController"
        }
        struct SegueIdentifiers {
            static let postSegue = "postNewArticle"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticPullingDownToRefresh()
        self.configureTableView()
        self.configureView()
        self.pullUpToLoadmore()
        self.sendRequest(page)
        
//        IBBSNodeCatalogueViewController.sharedInstance.sendRequest()
    }
    
    func sendRequest(page: Int) {
        
        APIClient.sharedInstance.getLatestTopics(page, success: { (json) -> Void in
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
                }
                
            }
            }, failure: { (error) -> Void in
                print(error)
                self.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        self.navigationController?.hidesBarsOnSwipe = true
        
        /**
        important: if present NavigationController's property of interactivePopGestureRecognizer is enable, we must set it to disable,
        otherwise if we call UIScreenEdgePanGestureRecognizer on present ViewController it will crash.
        */
        //        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    func configureView(){
        self.navigationController?.navigationBarHidden = false
        
        self.navigationItem.title = "iBBS"
        IBBSContext.sharedInstance.isLogin(){ (isLogin) -> Void in
            if isLogin {
                if let data = IBBSContext.sharedInstance.getLoginData() {
                    let username = data["username"].stringValue
                    self.navigationItem.title = username
                }
            }
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
    
    
    
}

extension IBBSViewController {
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            print(datasource.count)
            return datasource.count
            
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.iBBSTableViewCell) as? IBBSTableViewCell {
            let json = self.datasource[indexPath.row]
            print(json)
            
            cell.loadDataToCell(json)
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    // MARK: - table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let json = self.datasource[indexPath.row]
        //        if let vc = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.VCIdentifiers.detailVC) as? IBBSDetailViewController{
        //            vc.json = json
        //            self.navigationController?.pushViewController(vc, animated: true)
        //        }
        let vc = IBBSDetailViewController()
        vc.json = json
        vc.navigationController?.navigationBar.hidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension IBBSViewController {
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
            print("page: \(self.page)")
            
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

extension IBBSViewController: PostViewDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
                if segue.identifier == MainStoryboard.SegueIdentifiers.postSegue {
                    if let nav = segue.destinationViewController as? UINavigationController {
                        if let destinationVC = nav.viewControllers[0] as? IBBSPostViewController{
                            destinationVC.delegate = self
                        }
                    }
                }
//
    }
    func reloadDataAfterPosting() {
        print("reloading")
        self.tableView.reloadData()
        self.automaticPullingDownToRefresh()
    }
    

}










