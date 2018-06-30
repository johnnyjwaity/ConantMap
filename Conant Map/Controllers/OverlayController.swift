//
//  OverlayController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/7/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class OverlayController: UIViewController {
    
    let controllers:[UIViewController] = [RoomSearchController()]
    
    
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
        
        let rms = controllers[0]
        view.addSubview(rms.view)
        rms.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rms.view.bottomAnchor.constraint(equalTo: dragBar.topAnchor).isActive = true
        rms.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rms.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    
    

}
