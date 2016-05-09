//
//  IBBSFavoriteViewController.swift
//  iBBS
//
//  Created by Augus on 10/10/15.
//  Copyright © 2015 iAugus. All rights reserved.
//

import UIKit

class IBBSFavoriteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "close")?.imageWithRenderingMode(.AlwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(dismissViewController))

        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : CUSTOM_THEME_COLOR]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
