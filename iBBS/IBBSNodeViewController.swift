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

let postNewArticleWithNodeSegue = "postNewArticleWithNode"

class IBBSNodeViewController: IBBSBaseViewController, UIGestureRecognizerDelegate {
    
    var nodeJSON: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pullUpToLoadmore()
        configureTableView()
        configureGestureRecognizer()
        sendRequest(page)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadDataAfterPosting), name: kShouldReloadDataAfterPosting, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        cornerActionButton?.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.enabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        cornerActionButton?.hidden = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kShouldReloadDataAfterPosting, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        //        navigationController?.setNavigationBarHidden(true , animated: true)
        //        toggleSideMenuView()
    }

    private func sendRequest(page: Int) {
        
        guard let node = nodeJSON else { return }
        
        let id = IBBSNodeModel(json: node).id

        APIClient.defaultClient.getLatestTopics(id, page: page, success: { (json) -> Void in
            
            if json == nil && page != 1 {
                IBBSToast.make(NO_MORE_DATA, interval: TIME_OF_TOAST_OF_NO_MORE_DATA)
                return
            }
            
            if json.type == Type.Array {
                if page == 1 {
                    self.datasource = json.arrayValue
                    
                } else {
                    let appendArray = json.arrayValue
                    self.datasource? += appendArray
                }
                self.tableView.reloadData()
            }
            
            }, failure: { (error) -> Void in
                DEBUGLog(error)
                IBBSToast.make(SERVER_ERROR, interval: TIME_OF_TOAST_OF_SERVER_ERROR)
        })
    }
    
    private func configureView() {
        
        navigationController?.navigationBarHidden = false
        
        guard let node = nodeJSON else {
            title = "iBBS"
            return
        }
        
        let model = IBBSNodeModel(json: node)
        title = model.name
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(model.numberOfTotal), style: .Plain, target: self, action: nil)
    }
    
    private func configureTableView() {
        tableView.registerNib(UINib(nibName: String(IBBSNodeTableViewCell), bundle: nil ), forCellReuseIdentifier: String(IBBSNodeTableViewCell))
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func configureGestureRecognizer() {
        let edgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(toggleSideMenu(_:)))
        edgeGestureRecognizer.edges = UIRectEdge.Right
        view.addGestureRecognizer(edgeGestureRecognizer)
    }

    override func cornerActionButtonDidTap() {
        
        guard let node = nodeJSON else { return }
        
        let nodeId = IBBSNodeModel(json: node).id
        
        performPostNewArticleSegue(segueIdentifier: postNewArticleWithNodeSegue, nodeId: nodeId)
    }

}


extension IBBSNodeViewController {

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasource != nil {
            return datasource.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(String(IBBSNodeTableViewCell)) as? IBBSNodeTableViewCell else {
            return UITableViewCell()
        }
        
        let json = datasource[indexPath.row]
        cell.loadDataToCell(json)
        return cell
    }
    
    
    // MARK: - table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let json = datasource[indexPath.row]
        let destinationVC = IBBSDetailViewController()
        destinationVC.json = json
        
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}


extension IBBSNodeViewController {
    
    // MARK: - refresh
    override func refreshData() {
        super.refreshData()
        
        sendRequest(page)

        executeAfterDelay(0.9) {
            self.page = 1
            self.gearRefreshControl?.endRefreshing()
        }
    }

    
    // MARK: - pull up to load more
    func pullUpToLoadmore() {
        
        tableView.addFooterWithCallback({

            self.page += 1
            self.sendRequest(self.page)

            executeAfterDelay(1.0, completion: {
                self.tableView.footerEndRefreshing()
            })
        })
    }

}
