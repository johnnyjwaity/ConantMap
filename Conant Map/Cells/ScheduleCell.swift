//
//  ScheduleCell.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/10/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    var periodLabel:UILabel!
    var classLabel:UILabel!
    var teacherButton:UIButton!
    var roomButton:UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        print("Hello")
        backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        periodLabel = UILabel()
        periodLabel.translatesAutoresizingMaskIntoConstraints = false
        periodLabel.adjustsFontSizeToFitWidth = true
        periodLabel.textAlignment = .center
        periodLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        addSubview(periodLabel)
        periodLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        periodLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        periodLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        periodLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        
        
        
        let div = createDivider()
        addSubview(div)
        div.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        div.leftAnchor.constraint(equalTo: periodLabel.rightAnchor).isActive = true
        div.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        div.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        classLabel = UILabel()
//        classButton.backgroundColor = UIColor.blue
        classLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        classLabel.translatesAutoresizingMaskIntoConstraints = false
//        classLabel.lineBreakMode = .byWordWrapping
        classLabel.numberOfLines = 2
        classLabel.textAlignment = .center
        classLabel.adjustsFontSizeToFitWidth = true
        addSubview(classLabel)
        classLabel.leftAnchor.constraint(equalTo: periodLabel.rightAnchor).isActive = true
        classLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        classLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        classLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        let div2 = createDivider()
        addSubview(div2)
        div2.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        div2.leftAnchor.constraint(equalTo: classLabel.rightAnchor).isActive = true
        div2.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        div2.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        teacherButton = UIButton(type: .system)
//        teacherButton.backgroundColor = UIColor.yellow
        teacherButton.translatesAutoresizingMaskIntoConstraints = false
        teacherButton.titleLabel?.adjustsFontSizeToFitWidth = true
        teacherButton.tag = 0
        addSubview(teacherButton)
        teacherButton.leftAnchor.constraint(equalTo: classLabel.rightAnchor).isActive = true
        teacherButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        teacherButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        teacherButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        let div3 = createDivider()
        addSubview(div3)
        div3.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        div3.leftAnchor.constraint(equalTo: teacherButton.rightAnchor).isActive = true
        div3.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        div3.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        roomButton = UIButton(type: .system)
//        roomButton.backgroundColor = UIColor.green
        roomButton.translatesAutoresizingMaskIntoConstraints = false
        roomButton.titleLabel?.adjustsFontSizeToFitWidth = true
        roomButton.tag = 1
        addSubview(roomButton)
        roomButton.leftAnchor.constraint(equalTo: teacherButton.rightAnchor).isActive = true
        roomButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        roomButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        roomButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not SUpported")
    }
    
    func setInfo(_ period:Class){
        periodLabel.text = period.period
        classLabel.text = period.name
        var staffName = "No Teacher"
        teacherButton.isEnabled = false
        if let staff = period.potentialStaff {
            staffName = staff.name
            teacherButton.isEnabled = true
        }
        teacherButton.setTitle(staffName, for: .normal)
        roomButton.setTitle(period.location, for: .normal)
    }

    
    func createDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }
    

    

}
