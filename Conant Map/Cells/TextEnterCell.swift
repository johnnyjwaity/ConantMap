//
//  TextEnterCell.swift
//  Conant Map
//
//  Created by Johnny Waity on 9/30/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class TextEnterCell: UITableViewCell {
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(title:String, numericOnly:Bool) -> UITextField{
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let textEnter = UITextField()
        textEnter.placeholder = "Enter " + title
        textEnter.font = UIFont.systemFont(ofSize: 20)
        textEnter.translatesAutoresizingMaskIntoConstraints = false
        textEnter.textAlignment = .right
        textEnter.autocorrectionType = .no
        if numericOnly{
            textEnter.keyboardType = .phonePad
        }
        self.addSubview(textEnter)
        textEnter.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 150).isActive = true
        textEnter.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textEnter.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        textEnter.heightAnchor.constraint(equalToConstant: 55)
        return textEnter
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
