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
    var roomName:String!
    var populationArray:[UIView] = []
    
    var icon:UIImageView!
    var roomLbl:UILabel!
    
    let fromButton:UIButton = {
        let fromButton = UIButton(type: .system)
        fromButton.setTitle("From Here", for: .normal)
        fromButton.translatesAutoresizingMaskIntoConstraints = false
        fromButton.layer.cornerRadius = 8
        fromButton.setBackgroundImage(UIView().tintColor.toImage(), for: .normal)
        fromButton.setTitleColor(UIColor.white, for: .normal)
        fromButton.clipsToBounds = true
        fromButton.alpha = 0
        return fromButton
    }()
    
    let toButton:UIButton = {
        let toButton = UIButton(type: .system)
        toButton.setTitle("To Here", for: .normal)
        toButton.translatesAutoresizingMaskIntoConstraints = false
        toButton.layer.cornerRadius = 8
        toButton.setBackgroundImage(UIView().tintColor.toImage(), for: UIControl.State.normal)
        toButton.setTitleColor(UIColor.white, for: .normal)
        toButton.clipsToBounds = true
        toButton.alpha = 0
        return toButton
    }()
    
    let infoButton:UIButton = {
        let b = UIButton(type: .infoLight)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    
    let dropDown:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white
        return v
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func changeInfo(room:String){
        
        roomName = room
        
        fromButton.removeTarget(nil, action: nil, for: .allEvents)
        toButton.removeTarget(nil, action: nil, for: .allEvents)
        infoButton.removeTarget(nil, action: nil, for: .allEvents)
        
        if let structure = Global.structures.searchForStructure(room) {
            icon.tintColor = structure.color
            if structure.color == UIColor.white {
                icon.tintColor = UIColor.lightGray
            }
        }
        
        
        roomLbl.text = room
        
        for subView in infoButton.subviews {
            if let s = subView as? DataHolder {
                s.removeFromSuperview()
            }
        }
        let roomData = DataHolder()
        roomData.data["room"] = room
        infoButton.addSubview(roomData)
        
        
        for subView in toButton.subviews {
            if let s = subView as? DataHolder {
                s.removeFromSuperview()
            }
        }
        let data = DataHolder()
        data.isHidden = true
        data.data["room"] = room
        toButton.addSubview(data)
        
        
        for subView in fromButton.subviews {
            if let s = subView as? DataHolder {
                s.removeFromSuperview()
            }
        }
        let data2 = DataHolder()
        data2.isHidden = true
        data2.data["room"] = room
        fromButton.addSubview(data2)
    }
    
    func setUpCell() {
        for subView in populationArray{
            subView.removeFromSuperview()
        }
        populationArray = []
//        roomName = room
        clipsToBounds = true
        backgroundColor = UIColor.white
        
        let mainView = UIView()
        mainView.backgroundColor = UIColor.white
        mainView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainView)
        mainView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mainView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        mainView.heightAnchor.constraint(equalToConstant: 74).isActive = true
        populationArray.append(mainView)
        
        icon = UIImageView(image: #imageLiteral(resourceName: "GreyCircle"), highlightedImage: nil)
        icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
        
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(icon)
        let imageSize:CGFloat = 30
        icon.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 15).isActive = true
        icon.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        icon.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        icon.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        
        
        
        mainView.addSubview(infoButton)
        infoButton.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -10).isActive = true
        infoButton.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        
        roomLbl = UILabel()
        roomLbl.translatesAutoresizingMaskIntoConstraints = false
        roomLbl.font = UIFont.boldSystemFont(ofSize: 20)
//        roomLbl.numberOfLines = 0
//        roomLbl.lineBreakMode = .byWordWrapping
        roomLbl.adjustsFontSizeToFitWidth = true
        
        mainView.addSubview(roomLbl)
        roomLbl.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        roomLbl.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        roomLbl.rightAnchor.constraint(equalTo: infoButton.leftAnchor).isActive = true
        roomLbl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
        addSubview(dropDown)
        dropDownTopAnchor = dropDown.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -50)
        dropDownTopAnchor?.isActive = true
        dropDown.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        dropDown.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dropDown.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendSubviewToBack(dropDown)
        populationArray.append(dropDown)
        
        let linear = UIStackView(arrangedSubviews: [toButton, fromButton])
        linear.alignment = .fill
        linear.distribution = .fillEqually
        linear.axis = .horizontal
        linear.isLayoutMarginsRelativeArrangement = true
        linear.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        linear.translatesAutoresizingMaskIntoConstraints = false
        linear.setCustomSpacing(30, after: toButton)
        addSubview(linear)
        linear.leftAnchor.constraint(equalTo: dropDown.leftAnchor).isActive = true
        linear.centerYAnchor.constraint(equalTo: dropDown.centerYAnchor).isActive = true
        linear.widthAnchor.constraint(equalTo: dropDown.widthAnchor).isActive = true
        linear.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        populationArray.append(linear)
        
//        addSubview(toButton)
        //sendSubview(toBack: toButton)
//        populationArray.append(toButton)
//        toButton.widthAnchor.constraint(equalToConstant: 112.5).isActive = true
//        toButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        toButton.leftAnchor.constraint(equalTo: dropDown.leftAnchor, constant: 25).isActive = true
//        toButton.centerYAnchor.constraint(equalTo: dropDown.centerYAnchor).isActive = true
        
        
//        addSubview(fromButton)
//        populationArray.append(fromButton)
//        //sendSubview(toBack: fromButton)
//        fromButton.widthAnchor.constraint(equalToConstant: 112.5).isActive = true
//        fromButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        fromButton.leftAnchor.constraint(equalTo: toButton.rightAnchor, constant: 25).isActive = true
//        fromButton.centerYAnchor.constraint(equalTo: dropDown.centerYAnchor).isActive = true
        
    }
    
    func selected(){
        dropDownTopAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.5) {
            self.toButton.alpha = 1
            self.fromButton.alpha = 1
        }
    }
    func deselected(){
        dropDownTopAnchor?.constant = -50
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.2) {
            self.toButton.alpha = 0
            self.fromButton.alpha = 0
        }
    }
}
