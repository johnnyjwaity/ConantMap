//
//  NavigationWindowController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class NavigationWindowController: UIViewController {

    
    
    
//    let cancelButton:UIButton = {
//        let b = UIButton(type: UIButtonType.system)
//        b.setTitle("Cancel", for: UIControlState.normal)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        b.addTarget(self, action: #selector(cancelButtonClicked), for: UIControlEvents.touchUpInside)
//        return b
//    }()
    
    let pageViewController = NavigationPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }

    func setupView(){
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
        
        
        
        let pageView = pageViewController.view!
        view.addSubview(pageView)
        
        pageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        
        
    }
    
    
    

    

}

class NavigationPageViewController: UIPageViewController {
    
    var controllers:[UIViewController] = []
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let options = NavOptionsController()
        options.setPageContoller(cont: self)
        controllers.append(UINavigationController(rootViewController: options))
        let room1 = RoomSearchController()
        room1.setPageContoller(cont: self)
        controllers.append(UINavigationController(rootViewController: room1))
        let room2 = RoomSearchController()
        room2.setPageContoller(cont: self)
        controllers.append(UINavigationController(rootViewController: room2))
        
        
        //dataSource = self
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = UIColor.white
        let controllersInit:[UIViewController] = [placeholder]
        setViewControllers(controllersInit, direction: .forward, animated: true, completion: nil)
        //changePage(page: 0, direction: .forward, room: nil)
    }
    
    func changePage(page:Int, direction:UIPageViewControllerNavigationDirection, room:String?){
        setViewControllers([controllers[page]], direction: direction, animated: true, completion: nil)
        if let r = room {
            let navOptContNav = controllers[0] as! UINavigationController
            let navOptCont = navOptContNav.visibleViewController as! NavOptionsController
            switch currentPage {
                case 1:
                    navOptCont.buttons[0].roomLbl.text = r
                    break
                case 2:
                    navOptCont.buttons[1].roomLbl.text = r
                    break
                default:
                    break
            }
        }

        currentPage = page
    }
    
    
}


