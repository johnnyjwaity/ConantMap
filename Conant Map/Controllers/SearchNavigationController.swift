//
//  SearchNavigationController.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/27/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class SearchNavigationController: UINavigationController {
    
    var searchDelegate:SearchNavigationDelegate!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        print(viewControllers.count)
        if viewControllers.count <= 2 {
            print("Ran")
            searchDelegate.returnToSearch()
            setViewControllers([], animated: false)
            
        }
        let cont =  super.popViewController(animated: animated)
        
        return cont
    }

    

}
