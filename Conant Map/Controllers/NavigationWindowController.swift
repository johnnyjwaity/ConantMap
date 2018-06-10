//
//  NavigationWindowController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class NavigationWindowController: UIViewController {

    
    
    
    let cancelButton:UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.setTitle("Cancel", for: UIControlState.normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(cancelButtonClicked), for: UIControlEvents.touchUpInside)
        return b
    }()
    
    let pageViewController = NavigationPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }

    func setupView(){
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
        
        view.addSubview(cancelButton)
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        
        
        let pageView = pageViewController.view!
        view.addSubview(pageView)
        
        pageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9).isActive = true
        
        
        
    }
    
    @objc
    func cancelButtonClicked(){
        pageViewController.changePage(page:1)
    }
    

    

}

class NavigationPageViewController: UIPageViewController {
    
    let controllers:[UIViewController] = [NavOptionsController(), RoomSearchController(), RoomSearchController()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        //dataSource = self
        let controllersInit:[UIViewController] = [controllers[0]]
        setViewControllers(controllersInit, direction: .forward, animated: true, completion: nil)
    }
    
    func changePage(page:Int){
        setViewControllers([controllers[page]], direction: .forward, animated: true, completion: nil)
    }
}
