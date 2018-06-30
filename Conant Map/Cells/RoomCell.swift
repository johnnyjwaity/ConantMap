//
//  RoomCell.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/28/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell {

    var dropDownTopAnchor:NSLayoutConstraint? = nil
    
    
    let dropDown:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white
        let toButton = UIButton(type: UIButtonType.system)
        toButton.setTitle("To Here", for: .normal)
        toButton.backgroundColor = UIColor.blue
        toButton.translatesAutoresizingMaskIntoConstraints = false
        toButton.layer.cornerRadius = 8
        
        v.addSubview(toButton)
        toButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        toButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        toButton.leftAnchor.constraint(equalTo: v.leftAnchor, constant: 33.3).isActive = true
        toButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        
        
        let fromButton = UIButton(type: UIButtonType.system)
        fromButton.setTitle("From Here", for: .normal)
        fromButton.backgroundColor = UIColor.blue
        fromButton.translatesAutoresizingMaskIntoConstraints = false
        fromButton.layer.cornerRadius = 8
        
        
        v.addSubview(fromButton)
        fromButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        fromButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        fromButton.leftAnchor.constraint(equalTo: toButton.rightAnchor, constant: 33.3).isActive = true
        fromButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        
        
        return v
    }()
    
    
    func setUpCell(room:String) {
        clipsToBounds = true
        backgroundColor = UIColor.white
        
        let mainView = UIView()
        mainView.backgroundColor = UIColor.white
        mainView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainView)
        mainView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mainView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        mainView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        let icon = UIImageView(image: #imageLiteral(resourceName: "GreyCircle"), highlightedImage: nil)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(icon)
        let imageSize:CGFloat = 30
        icon.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 15).isActive = true
        icon.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        icon.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        icon.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        
        let roomLbl = UILabel()
        roomLbl.translatesAutoresizingMaskIntoConstraints = false
        roomLbl.font = UIFont.boldSystemFont(ofSize: 20)
        roomLbl.numberOfLines = 0
        roomLbl.lineBreakMode = .byWordWrapping
        roomLbl.text = room
        mainView.addSubview(roomLbl)
        roomLbl.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        roomLbl.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        roomLbl.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        roomLbl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        addSubview(dropDown)
        dropDownTopAnchor = dropDown.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -25)
        dropDownTopAnchor?.isActive = true
        dropDown.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        dropDown.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dropDown.heightAnchor.constraint(equalToConstant: 25).isActive = true
        sendSubview(toBack: dropDown)
        
    }
    
    func selected(){
        dropDownTopAnchor?.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
    func deselected(){
        dropDownTopAnchor?.constant = -25
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
}
