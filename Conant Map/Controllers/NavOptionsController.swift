//
//  NavOptionsController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class NavOptionsController: UIViewController {

    var fromRoom = "Select"
    let fromButton = UIButton(type: .system)
    var toRoom = "Select"
    let toButton = UIButton(type: .system)

    let routeButton = UIButton(type: UIButtonType.system)
    
    var delegate:NavOptionsDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView(){
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "My Route"
        title.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(title)
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        
        routeButton.translatesAutoresizingMaskIntoConstraints = false
        routeButton.setTitle("Route", for: .normal)
        routeButton.isEnabled = false
        routeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(routeButton)
        routeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        routeButton.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        
        
        let toFromContainer = UIView()
        toFromContainer.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        toFromContainer.layer.cornerRadius = 8
        toFromContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toFromContainer)
        toFromContainer.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 25).isActive = true
        toFromContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toFromContainer.heightAnchor.constraint(equalToConstant: 75).isActive = true
        toFromContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        toFromContainer.addSubview(divider)
        divider.centerXAnchor.constraint(equalTo: toFromContainer.centerXAnchor).isActive = true
        divider.centerYAnchor.constraint(equalTo: toFromContainer.centerYAnchor).isActive = true
        divider.widthAnchor.constraint(equalTo: toFromContainer.widthAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        let fromLabel = UILabel()
        fromLabel.text = "From:"
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        fromLabel.textColor = UIColor.lightGray
        toFromContainer.addSubview(fromLabel)
        fromLabel.leftAnchor.constraint(equalTo: toFromContainer.leftAnchor, constant: 10).isActive = true
        fromLabel.topAnchor.constraint(equalTo: toFromContainer.topAnchor).isActive = true
        fromLabel.bottomAnchor.constraint(equalTo: divider.topAnchor).isActive = true
        
        let toLabel = UILabel()
        toLabel.text = "To:"
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.textColor = UIColor.lightGray
        toFromContainer.addSubview(toLabel)
        toLabel.leftAnchor.constraint(equalTo: toFromContainer.leftAnchor, constant: 10).isActive = true
        toLabel.topAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
        toLabel.bottomAnchor.constraint(equalTo: toFromContainer.bottomAnchor).isActive = true
        
        fromButton.setTitle(fromRoom, for: .normal)
        fromButton.translatesAutoresizingMaskIntoConstraints = false
        toFromContainer.addSubview(fromButton)
        fromButton.leftAnchor.constraint(equalTo: fromLabel.rightAnchor, constant: 5).isActive = true
        fromButton.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor).isActive = true
        fromButton.addTarget(self, action: #selector(selectButtonClicked(sender:)), for: .touchUpInside)
        fromButton.tag = 0
        
        toButton.setTitle(toRoom, for: .normal)
        toButton.translatesAutoresizingMaskIntoConstraints = false
        toFromContainer.addSubview(toButton)
        toButton.leftAnchor.constraint(equalTo: toLabel.rightAnchor, constant: 5).isActive = true
        toButton.centerYAnchor.constraint(equalTo: toLabel.centerYAnchor).isActive = true
        toButton.addTarget(self, action: #selector(selectButtonClicked(sender:)), for: .touchUpInside)
        toButton.tag = 1
        
        let switchBackground = UIView()
        switchBackground.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        switchBackground.layer.cornerRadius = 8
        switchBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchBackground)
        switchBackground.topAnchor.constraint(equalTo: toFromContainer.bottomAnchor, constant: 30).isActive = true
        switchBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        switchBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        switchBackground.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let elevatorLabel = UILabel()
        elevatorLabel.text = "Use Elevators"
        elevatorLabel.translatesAutoresizingMaskIntoConstraints = false
        elevatorLabel.textColor = UIColor.lightGray
        switchBackground.addSubview(elevatorLabel)
        elevatorLabel.leftAnchor.constraint(equalTo: switchBackground.leftAnchor, constant: 10).isActive = true
        elevatorLabel.centerYAnchor.constraint(equalTo: switchBackground.centerYAnchor).isActive = true
        
        let elevatorSwitch = UISwitch()
        elevatorSwitch.translatesAutoresizingMaskIntoConstraints = false
        switchBackground.addSubview(elevatorSwitch)
        elevatorSwitch.rightAnchor.constraint(equalTo: switchBackground.rightAnchor, constant: -10).isActive = true
        elevatorSwitch.centerYAnchor.constraint(equalTo: switchBackground.centerYAnchor).isActive = true
        
    }
    
    @objc
    func selectButtonClicked(sender:UIButton){
        delegate.findRoomRequested(location: ((sender.tag == 0) ? NavPosition.From : NavPosition.To))
    }
    
    
    func setRoom(pos:NavPosition, room:String) {
        switch pos {
        case .To:
            toRoom = room
            toButton.setTitle(room, for: .normal)
            break
        case .From:
            fromRoom = room
            fromButton.setTitle(room, for: .normal)
            break
        default:
            break
        }
        if toRoom != "Select" && fromRoom != "Select" {
            routeButton.isEnabled = true
        }
    }

}
