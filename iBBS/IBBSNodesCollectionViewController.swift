//
//  IBBSNodesCollectionViewController.swift
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

class IBBSNodesCollectionViewController: UICollectionViewController {
    
    
    var nodesArray: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IBBSConfigureNodesInfo.sharedInstance.configureNodesInfo()
        self.nodesArray = IBBSConfigureNodesInfo.sharedInstance.nodesArray
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.topItem?.title = TITLE_ALL_NODES
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CUSTOM_THEME_COLOR]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.nodesArray?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MainStoryboard.CollectionCellIdentifiers.nodeCollectionCell, forIndexPath: indexPath) as? IBBSNodesCollectionViewCell {
            
            if let array = self.nodesArray {
                let json = array[indexPath.row]
                print(json)
                cell.infoLabel?.text = json["name"].stringValue
                
            }
            return cell

        }
        return UICollectionViewCell()
    }
  
    // MARK: - Collection view delegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let array = self.nodesArray {
            let json = array[indexPath.row]
            print(json)
            if let vc = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.VCIdentifiers.nodeVC) as? IBBSNodeViewController {
                vc.nodeJSON = json
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
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

public class IBBSConfigureNodesInfo {
    
    static let sharedInstance = IBBSConfigureNodesInfo()
    private init(){}
    
    public var nodesArray: [JSON]?
    
    public func configureNodesInfo(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let nodes = IBBSContext.sharedInstance.getNodes()
            dispatch_async(dispatch_get_main_queue(), {
                if let json = nodes {
                    IBBSConfigureNodesInfo.sharedInstance.nodesArray = json.arrayValue
                } else {
                    IBBSConfigureNodesInfo.sharedInstance.getNodesIfNeeded()
                }
            })
        })
    }
    
    private func getNodesIfNeeded() {
        APIClient.sharedInstance.getNodes({ (json) -> Void in
            if json.type == Type.Array {
                self.nodesArray = json.arrayValue
                print(json.arrayValue)
                IBBSContext.sharedInstance.saveNodes(json.object)
            }
            }) { (error) -> Void in
                UIApplication.topMostViewController()?.view.makeToast(message: SERVER_ERROR, duration: TIME_OF_TOAST_OF_SERVER_ERROR, position: HRToastPositionTop)
                
        }
    }
}
