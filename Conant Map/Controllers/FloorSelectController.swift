//
//  OptionsController.swift
//  Conant Map
//
//  Created by Johnny Waity on 7/4/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class FloorSelectController: UIViewController {
    
    let floor1Button = UIButton(type: .system)
    let floor2Button = UIButton(type: .system)
    
    var delegate:FloorSelectDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView(){
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        
        floor1Button.setTitle("1", for: .normal)
        floor1Button.setTitleColor(UIColor.white, for: .normal)
        floor1Button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 23)
        floor1Button.backgroundColor = UIView().tintColor
        floor1Button.translatesAutoresizingMaskIntoConstraints = false
        floor1Button.tag = 1
        view.addSubview(floor1Button)
        floor1Button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        floor1Button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        floor1Button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        floor1Button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        floor1Button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        
        
        floor2Button.setTitle("2", for: .normal)
        floor2Button.setTitleColor(UIView().tintColor, for: .normal)
        floor2Button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 23)
        floor2Button.backgroundColor = UIColor.white
        floor2Button.translatesAutoresizingMaskIntoConstraints = false
        floor2Button.tag = 2
        view.addSubview(floor2Button)
        floor2Button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        floor2Button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        floor2Button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        floor2Button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        floor2Button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        
        
    }
    
    @objc
    func buttonClick(sender:UIButton){
        switchButton(floor1Button)
        switchButton(floor2Button)
        delegate.changeFloor(sender.tag)
    }
    
    func switchButton(_ button:UIButton){
        button.setTitleColor(((button.titleLabel?.textColor == UIColor.white) ? UIView().tintColor : UIColor.white), for: .normal)
        UIView.animate(withDuration: 0.3) {
            button.backgroundColor = ((button.backgroundColor == UIColor.white) ? UIView().tintColor : UIColor.white)
        }
    }

}
