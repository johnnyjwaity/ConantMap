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
        scheduleButton.setBackgroundImage(#imageLiteral(resourceName: "clock"), for: .normal)
        scheduleButton.contentMode = .scaleAspectFit
        scheduleButton.imageEdgeInsets = UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0)
        scheduleButton.addTarget(self, action: #selector(openSchedule), for: .touchUpInside)
        controls.append(scheduleButton)
        
//        let labelButton = UIButton(type: .system)
//        labelButton.setTitle("Aa", for: .normal)
//        labelButton.translatesAutoresizingMaskIntoConstraints = false
//        labelButton.addTarget(self, action: #selector(toggleLabels(_:)), for: .touchUpInside)
//        labelButton.backgroundColor = UIView().tintColor
//        controls.append(labelButton)
        
        var prevView:UIView? = nil
        for control in controls {
            view.addSubview(control)
            control.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            control.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CGFloat(1.0 / Double(controls.count))).isActive = true
            control.topAnchor.constraint(equalTo: (prevView != nil) ? (prevView?.bottomAnchor)! : view.topAnchor).isActive = true
            control.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            prevView = control
        }
    }
    
    
    @objc
    func openSchedule(){
        delegate.openSchedule()
    }

}
