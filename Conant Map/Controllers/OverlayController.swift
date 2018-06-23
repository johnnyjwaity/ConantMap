//
//  OverlayController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/7/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class OverlayController: UIViewController {
    
    let p:GameViewController

    
    
    let navigationButton:UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.setTitle("Start Route", for: UIControlState.normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIView().tintColor
        b.setTitleColor(UIColor.white, for: UIControlState.normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        b.addTarget(self, action: #selector(navButtonClicked), for: UIControlEvents.touchUpInside)
        b.layer.cornerRadius = 8
        return b
    }()
    
    let floorChooser:UISegmentedControl = {
        let s = UISegmentedControl(items: ["Floor 1", "Floor 2"])
        s.translatesAutoresizingMaskIntoConstraints = false
        s.selectedSegmentIndex = 0
        return s
    }()
    
    init(parentController:GameViewController) {
        self.p = parentController
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    @objc
    func navButtonClicked(){
        self.p.navWindowCont?.pageViewController.changePage(page: 0, direction: .forward, room: nil)
        for c:UIViewController in (self.p.navWindowCont?.pageViewController.controllers)! {
            if let nc = c as? UINavigationController {
                if let rs = nc.visibleViewController as? RoomSearchController {
                    print("Loaded Data")
                    rs.rooms = UserDefaults.standard.array(forKey: "rooms") as! [String]
                    rs.displayedRooms = rs.rooms
                    rs.table.reloadData()
                }
                
            }
        }
        
        self.p.animate()
    }
    
    func setupView(){
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        
        
//        view.addSubview(mainView)
//        mainViewConstraints["Right"] = mainView.rightAnchor.constraint(equalTo: view.rightAnchor)
//        mainViewConstraints["Left"] = mainView.leftAnchor.constraint(equalTo: view.leftAnchor)
//        mainViewConstraints["Top"] = mainView.topAnchor.constraint(equalTo: view.topAnchor)
//        mainViewConstraints["Bottom"] = mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        for c:NSLayoutConstraint in mainViewConstraints.values {
//            c.isActive = true
//        }
        
        view.addSubview(navigationButton)
        navigationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        navigationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33).isActive = true
        navigationButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        navigationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        
        
        view.addSubview(floorChooser)
        floorChooser.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        floorChooser.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25).isActive = true
        floorChooser.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
        
        floorChooser.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        
        
        let grab = UIView()
        view.addSubview(grab)
        grab.backgroundColor = UIColor.lightGray
        grab.translatesAutoresizingMaskIntoConstraints = false
        grab.layer.cornerRadius = 5
        grab.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        grab.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        grab.widthAnchor.constraint(equalToConstant: 50).isActive = true
        grab.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        
        
        
    }
    
    
    func swiped (){
        view.backgroundColor = UIColor.red
    }

    
    


}
