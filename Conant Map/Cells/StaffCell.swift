//
//  StaffCell.swift
//  Conant Map
//
//  Created by Johnny Waity on 12/28/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class StaffCell: UITableViewCell {
    var staffName:String!
    var icon:UIImageView!
    var staffLbl:UILabel!
    var departmentLbl:UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        backgroundColor = UIColor.white
        
        icon = UIImageView(image: #imageLiteral(resourceName: "GreyCircle"), highlightedImage: nil)
        icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        let imageSize:CGFloat = 30
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        icon.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        
        staffLbl = UILabel()
        staffLbl.translatesAutoresizingMaskIntoConstraints = false
        staffLbl.font = UIFont.boldSystemFont(ofSize: 20)
        staffLbl.numberOfLines = 0
        staffLbl.lineBreakMode = .byWordWrapping
        
        addSubview(staffLbl)
        staffLbl.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        staffLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        staffLbl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        staffLbl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        departmentLbl = UILabel()
        departmentLbl.translatesAutoresizingMaskIntoConstraints = false
        departmentLbl.font = UIFont.systemFont(ofSize: 15)
        departmentLbl.textColor = UIColor.lightGray
        departmentLbl.numberOfLines = 0
        departmentLbl.lineBreakMode = .byWordWrapping
        departmentLbl.text = "Test Text"
        
        addSubview(departmentLbl)
        departmentLbl.topAnchor.constraint(equalTo: staffLbl.bottomAnchor, constant: -5).isActive = true
        departmentLbl.leftAnchor.constraint(equalTo: staffLbl.leftAnchor).isActive = true
        departmentLbl.rightAnchor.constraint(equalTo: staffLbl.rightAnchor).isActive = true
    }
    func changeInfo(_ staff:Staff){
        staffName = staff.name
        staffLbl.text = staffName
        let department = staff.department!
        departmentLbl.text = department
        var color:UIColor!
        if department.contains("English"){
            color = UIColor.black
        }else{
            switch department {
            case "Student Services":
                color = UIColor.purple
                break
            case "Math":
                color = UIColor.red
                break
            case "Physical Education":
                color = UIColor.yellow
                break
            case "World Language":
                color = UIColor.brown
                break
            case "Social Studies":
                color = UIColor.blue
                break
            case "Family and Consumer Sciences":
                color = UIColor.orange
                break
            case "Business Education":
                color = UIColor.cyan
                break
            case "Art":
                color = UIColor.magenta
                break
            case "Science":
                color = UIColor.green
                break
            case "Special Education":
                color = UIColor.darkGray
                break
            case "Music":
                color = UIColor.magenta
                break
            case "Applied Technology":
                color = UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1)
                break
            case "Driver Education":
                color = UIColor.init(red: 0, green: 0.467, blue: 0.745, alpha: 1)
                break
            case "Health":
                color = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1)
                break
            default:
                print("No Color For \(department)")
                color = UIView().tintColor
                break
            }
        }
        icon.tintColor = color
    }

}
