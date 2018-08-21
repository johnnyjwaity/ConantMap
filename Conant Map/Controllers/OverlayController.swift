//
//  OverlayController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/7/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class OverlayController: UIViewController, RoomSearchDelegate, NavOptionsDelegate {
    
    
    
    var currentController:UIViewController!
    var controllers:[String:UIViewController] = [:]
    
    var delegate:OverlayDelegate!
    
    let dragBar:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 8
        let topBar:UIView = {
            let b:UIView = UIView()
            b.translatesAutoresizingMaskIntoConstraints = false
            b.backgroundColor = UIColor.lightGray
            return b
        }()
        
        v.addSubview(topBar)
        topBar.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
        topBar.leftAnchor.constraint(equalTo: v.leftAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: v.rightAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        let slider:UIView = {
            let s:UIView = UIView()
            s.translatesAutoresizingMaskIntoConstraints = false
            s.backgroundColor = UIColor.lightGray
            s.layer.cornerRadius = 5
            return s
        }()
        v.addSubview(slider)
        slider.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        slider.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 7).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        return v
    }()
    
    let pageView = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }

    func setupView(){
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        view.addSubview(dragBar)
        dragBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        dragBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        dragBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dragBar.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        
//        view.addSubview(rms.view)
//        rms.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        rms.view.bottomAnchor.constraint(equalTo: dragBar.topAnchor).isActive = true
//        rms.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        rms.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        view.addSubview(pageView.view)
        pageView.view.translatesAutoresizingMaskIntoConstraints = false
        pageView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pageView.view.bottomAnchor.constraint(equalTo: dragBar.topAnchor).isActive = true
        pageView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pageView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        let rms = RoomSearchController()
        rms.delegate = self
        currentController = rms
        pageView.setViewControllers([rms], direction: .forward, animated: false, completion: nil)
        
    }
    
    func roomSelected(controller: RoomSearchController, name: String, pos: NavPosition) {
        print(name)
        if let navOptionsController = controllers["NavOptions"] {
            let navOptions = navOptionsController as! NavOptionsController
            navOptions.setRoom(pos: pos, room: name)
            changePage(navOptions, direction: .reverse)
        }
        else{
            let navOptions = NavOptionsController()
            navOptions.delegate = self
            navOptions.setRoom(pos: pos, room: name)
            controllers["NavOptions"] = navOptions
            changePage(navOptions, direction: .forward)
        }
    }
    
    func findRoomRequested(location: NavPosition) {
        if let r = controllers["RoomController"] {
            let rms = r as! RoomSearchController
            rms.searchingFor = location
            changePage(rms, direction: .forward)
        }
        else {
            let rms = RoomSearchController(location)
            rms.delegate = self
            controllers["RoomController"] = rms
            changePage(rms, direction: .forward)
        }
    }
    
    func showRoomInfo(controller: RoomSearchController, room: String) {
        if let i = controllers["RoomInfoController"]{
            let infoController = i as! RoomInfoController
            infoController.setRoom(room)
            changePage(infoController, direction: .forward)
            delegate.resizeOverlay(.Medium)
        }
        else{
            let infoController = RoomInfoController()
            infoController.setRoom(room)
            controllers["RoomInfoController"] = infoController
            changePage(infoController, direction: .forward)
            delegate.resizeOverlay(.Medium)
        }
    }
    
    func resetRoute() {
        reset()
    }
    
    func reset(){
        controllers = [:]
        let rms = RoomSearchController()
        rms.delegate = self
        currentController = rms
        pageView.setViewControllers([rms], direction: .reverse, animated: true, completion: nil)
        delegate.resizeOverlay(.Large)
    }
    
    func changePage(_ controller:UIViewController, direction:UIPageViewControllerNavigationDirection){
        currentController = controller
        pageView.setViewControllers([controller], direction: direction, animated: true, completion: nil)
        if let del = delegate {
            if (currentController as? RoomSearchController) != nil {
                del.resizeOverlay(.Large)
            }
            else if (currentController as? NavOptionsController) != nil {
                del.resizeOverlay(.Medium)
            }
        }
    }

    
    func startRoute(_ session: NavigationSession) {
        delegate.startNavigation(session)
    }
}
