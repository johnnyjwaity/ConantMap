//
//  DateEnterCell.swift
//  Conant Map
//
//  Created by Johnny Waity on 9/30/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class DateEnterCell: UITableViewCell {
    
    var dateLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(title:String) -> UIDatePicker{
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 55).isActive = true
        self.clipsToBounds = true
        let datePicker = UIDatePicker()
        print(datePicker.intrinsicContentSize.height)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        self.addSubview(datePicker)
        datePicker.clipsToBounds = true
        datePicker.topAnchor.constraint(equalTo: self.topAnchor, constant: 55).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .right
        dateLabel.textColor = UIView().tintColor
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .none
        let dateValue = dateformatter.string(from: datePicker.date)
        dateLabel.text = dateValue
        self.addSubview(dateLabel)
        dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        dateLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        return datePicker
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
