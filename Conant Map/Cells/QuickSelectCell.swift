//
//  QuickSelectCell.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/23/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class QuickSelectCell: UITableViewCell {
    var quickButtons:[QuickButton] = []
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        setupCell()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(){
        let gym = QuickButton(name: "Gym", color: UIColor.orange, glyph: #imageLiteral(resourceName: "basketball"))
        let caf = QuickButton(name: "Cafeteria", color: UIColor.red, glyph: #imageLiteral(resourceName: "hamburger"))
        let lib = QuickButton(name: "Library", color: UIColor.purple, glyph: #imageLiteral(resourceName: "open-book"))
        let atr = QuickButton(name: "Atrium", color: UIColor.green, glyph: #imageLiteral(resourceName: "sun"))
        
        quickButtons = [gym, caf, lib, atr]
        
        var lastButton:QuickButton? = nil
        for btn in quickButtons {
            btn.translatesAutoresizingMaskIntoConstraints = false
            addSubview(btn)
            btn.topAnchor.constraint(equalTo: topAnchor).isActive = true
            btn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            btn.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(1.0 / Double(quickButtons.count))).isActive = true
            btn.leftAnchor.constraint(equalTo: (lastButton != nil) ? lastButton!.rightAnchor : leftAnchor).isActive = true
            lastButton = btn
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class QuickButton: UIView {
    var icon:UIButton!
    let name:String
    
    init(name:String, color:UIColor, glyph:UIImage) {
        self.name = name
        super.init(frame: CGRect.zero)
        
        icon = UIButton(type: .system)
        var img = #imageLiteral(resourceName: "GreyCircle")
        img = img.withRenderingMode(.alwaysTemplate)
        icon.setBackgroundImage(img, for: .normal)
        icon.tintColor = color
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 45).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let glyphView = UIImageView(image: glyph)
        glyphView.translatesAutoresizingMaskIntoConstraints = false
        icon.addSubview(glyphView)
        glyphView.centerXAnchor.constraint(equalTo: icon.centerXAnchor).isActive = true
        glyphView.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        glyphView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        glyphView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let title = UILabel()
        title.text = name
        title.font = UIFont.boldSystemFont(ofSize: 13)
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
