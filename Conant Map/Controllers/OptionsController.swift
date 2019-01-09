//
//  OptionsController.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/23/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class OptionsController: UIViewController {

    var controls:[UIButton] = []
    var delegate:OptionsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        
        let scheduleButton = UIButton(type: .system)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.setBackgroundImage(#imageLiteral(resourceName: "clock").withRenderingMode(.alwaysTemplate), for: .normal)
        scheduleButton.contentMode = .scaleAspectFit
//        scheduleButton.imageEdgeInsets = UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0)
        scheduleButton.addTarget(self, action: #selector(openSchedule), for: .touchUpInside)
        controls.append(scheduleButton)
        
        let staffButton = UIButton(type: .system)
        staffButton.translatesAutoresizingMaskIntoConstraints = false
        staffButton.setBackgroundImage(#imageLiteral(resourceName: "people").withRenderingMode(.alwaysTemplate), for: .normal)
        staffButton.contentMode = .scaleAspectFit
        staffButton.addTarget(self, action: #selector(openStaffFinder), for: .touchUpInside)
        controls.append(staffButton)
        
        let settingsButton = UIButton(type: .system)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setBackgroundImage(#imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate), for: .normal)
        settingsButton.contentMode = .scaleAspectFit
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        controls.append(settingsButton)
        
        
        
        var prevView:UIView? = nil
        for control in controls {
            view.addSubview(control)
            control.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
            control.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
            control.topAnchor.constraint(equalTo: (prevView != nil) ? (prevView?.bottomAnchor)! : view.topAnchor, constant: 5).isActive = true
            control.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            prevView = control
        }
    }
    
    
    @objc
    func openSchedule(){
        delegate.openSchedule()
    }
    @objc
    func openStaffFinder(){
        delegate.openStaffFinder()
    }
    @objc
    func openSettings(){
        delegate.openSettings()
    }

}
