//
//  IBBSIdentifiers.swift
//  iBBS
//
//  Created by Augus on 10/5/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())

struct MainStoryboard {

    struct VCIdentifiers {
        static let editVC                      = "iBBSEditingViewController"
        static let detailVC                    = "iBBSDetailViewController"
        static let nodeVC                      = "iBBSNodeViewController"

    }

    struct CellIdentifiers {
        static let iBBSTableViewCell           = "iBBSTableViewCell"
        static let iBBSNodeTableViewCell       = "iBBSNodeTableViewCell"
        static let messageCell                 = "iBBSMessageTableViewCell"
        static let replyCell                   = "iBBSReplyCell"
    }

    struct CollectionCellIdentifiers {
        static let nodeCollectionCell          = "iBBSNodesCollectionViewCell"
    }

    struct NibIdentifiers {
        static let iBBSTableViewCell           = "IBBSTableViewCell"
        static let iBBSNodeTableViewCellName   = "IBBSNodeTableViewCell"
        static let replyCell                   = "IBBSReplyCell"
        static let headerView                  = "IBBSDetailHeaderView"
        static let messageCell                 = "IBBSMessageTableViewCell"
    }

    struct SegueIdentifiers {
        static let postSegue                   = "postNewArticle"
        static let nodeToMainVCSegueIdentifier = "nodeToMainVC"

    }
}
