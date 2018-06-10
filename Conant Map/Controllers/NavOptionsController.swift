//
//  NavOptionsController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class NavOptionsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    
    
    

    func setupView(){
        view.backgroundColor = UIColor.white
        let b = SelectButton(text:"From:")
        view.addSubview(b)
        b.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        b.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        b.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive = true
        b.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let b2 = SelectButton(text:"To:")
        view.addSubview(b2)
        b2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        b2.topAnchor.constraint(equalTo: b.bottomAnchor, constant: 20).isActive = true
        b2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive = true
        b2.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    

    

}

class SelectButton:UIButton {
    
    let labelText:String
    
    init(text:String) {
        labelText = text
        super.init(frame: .zero)
        setupView()
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    func setupView(){
        backgroundColor = UIColor.white
        setTitle("", for: .normal)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        let lbl:UILabel = {
            let l = UILabel()
            l.text = labelText
            l.translatesAutoresizingMaskIntoConstraints = false
            
            return l
        }()
        
        addSubview(lbl)
        lbl.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        lbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lbl.widthAnchor.constraint(equalToConstant: 75).isActive = true
        lbl.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
        let point:UIImageView = {
            let i = UIImageView()
            i.image = #imageLiteral(resourceName: "arrow")
            i.contentMode = UIViewContentMode.scaleAspectFit
            i.translatesAutoresizingMaskIntoConstraints = false
            return i
        }()
        addSubview(point)
        point.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        point.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        point.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        point.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        let roomLbl:UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.text = "Unselected..."
            l.font = UIFont.italicSystemFont(ofSize: 16)
            return l
        }()
        
        addSubview(roomLbl)
        roomLbl.leftAnchor.constraint(equalTo: lbl.rightAnchor, constant: 10).isActive = true
        roomLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        roomLbl.rightAnchor.constraint(equalTo: point.leftAnchor).isActive = true
        roomLbl.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
    }
    
    override open var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2){
                self.backgroundColor = self.isHighlighted ? UIColor.lightGray : UIColor.white
            }
            
        }
    }
    @objc
    func clicked(){
        if isHighlighted {
            backgroundColor = UIColor.lightGray
        }
        else {
            backgroundColor = UIColor.white
        }
    }
    
    
}
