//
//  RoomInfoController.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/17/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class RoomInfoController: UIViewController {
    
    let room:String
    
    init(room:String) {
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }
    
    var staffButtons:[UIButton:Class] = [:]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not Supported")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = room
        view = UIScrollView()
        
        setupView()
    }
    
    let fromButton:UIButton = {
        let fromButton = UIButton(type: .system)
        fromButton.setTitle("From Here", for: .normal)
        fromButton.translatesAutoresizingMaskIntoConstraints = false
        fromButton.layer.cornerRadius = 8
        fromButton.setBackgroundImage(UIView().tintColor.toImage(), for: .normal)
        fromButton.setTitleColor(UIColor.white, for: .normal)
        fromButton.clipsToBounds = true
        fromButton.alpha = 1
        fromButton.tag = 0
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
        toButton.alpha = 1
        toButton.tag = 1
        return toButton
    }()

    func setupView(){
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        var roomClasses:[Class] = []
        for c in Global.classes {
            if c.location.lowercased() == room.lowercased() {
                roomClasses.append(c)
            }
        }
        var sorted:[String:[Class]] = [:]
        for c in roomClasses {
            print(c.name)
            print(c.period)
            print(c.location)
            if let pList = sorted[c.period]{
                var isDuplicate = false
                for c1 in pList{
                    if(c.period == c1.period && c.staff.name == c1.staff.name){
                        //Duplicate
                        isDuplicate = true
                    }
                }
                if !isDuplicate{
                    sorted[c.period]?.append(c)
                }
                
            }
            else{
                sorted[c.period] = [c]
            }
        }
        var fullySorted:[Class] = []
        if let p1 = sorted["1"]{
            fullySorted.append(contentsOf: p1)
        }
        if let p2 = sorted["2"]{
            fullySorted.append(contentsOf: p2)
        }
        if let p3 = sorted["3"]{
            fullySorted.append(contentsOf: p3)
        }
        if let p4 = sorted["4"]{
            fullySorted.append(contentsOf: p4)
        }
        if let p5 = sorted["5"]{
            fullySorted.append(contentsOf: p5)
        }
        if let p6 = sorted["6"]{
            fullySorted.append(contentsOf: p6)
        }
        if let p7 = sorted["7"]{
            fullySorted.append(contentsOf: p7)
        }
        if let p8 = sorted["8"]{
            fullySorted.append(contentsOf: p8)
        }
        if let ac = sorted["AC"]{
            fullySorted.append(contentsOf: ac)
        }
        
        let scroll = view as! UIScrollView
        scroll.contentSize = CGSize(width: view.bounds.width, height: CGFloat(50 * fullySorted.count + 200))
        
        view.addSubview(fromButton)
        fromButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        fromButton.widthAnchor.constraint(equalToConstant: 112.5).isActive = true
        fromButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        fromButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -25/2).isActive = true
        fromButton.addTarget(self, action: #selector(navigateButton(_:)), for: .touchUpInside)
        
        view.addSubview(toButton)
        toButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        toButton.widthAnchor.constraint(equalToConstant: 112.5).isActive = true
        toButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        toButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 25/2).isActive = true
        toButton.addTarget(self, action: #selector(navigateButton(_:)), for: .touchUpInside)
        
        let infoPicker = UISegmentedControl(items: ["Staff", "Class"])
        infoPicker.translatesAutoresizingMaskIntoConstraints = false
        infoPicker.selectedSegmentIndex = 0
        view.addSubview(infoPicker)
        infoPicker.topAnchor.constraint(equalTo: toButton.bottomAnchor, constant: 20).isActive = true
        infoPicker.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        infoPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoPicker.addTarget(self, action: #selector(changeTableDisplay(sender:)), for: .valueChanged)
        
        
        let scheduleBackground = UIView()
        scheduleBackground.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        scheduleBackground.translatesAutoresizingMaskIntoConstraints = false
        scheduleBackground.layer.cornerRadius = 8
        scheduleBackground.clipsToBounds = true
        view.addSubview(scheduleBackground)
        scheduleBackground.topAnchor.constraint(equalTo: infoPicker.bottomAnchor, constant: 10).isActive = true
        scheduleBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        scheduleBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scheduleBackground.heightAnchor.constraint(equalToConstant: CGFloat(50 * fullySorted.count)).isActive = true
        
        
        var lastView = scheduleBackground
        for c in fullySorted {
            let listingContainer = UIView()
            listingContainer.backgroundColor = UIColor.clear
            listingContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let periodLabel = UILabel()
            periodLabel.text = ("Period " + c.period) + ":"
            periodLabel.translatesAutoresizingMaskIntoConstraints = false
            periodLabel.adjustsFontSizeToFitWidth = true
            periodLabel.textColor = UIColor.lightGray
            
            listingContainer.addSubview(periodLabel)
            periodLabel.leftAnchor.constraint(equalTo: listingContainer.leftAnchor, constant: 5).isActive = true
            periodLabel.centerYAnchor.constraint(equalTo: listingContainer.centerYAnchor).isActive = true
            periodLabel.widthAnchor.constraint(equalTo: listingContainer.widthAnchor, multiplier: 0.4).isActive = true

            let teacherButton = UIButton(type: .system)
            teacherButton.setTitle(c.staff.name, for: .normal)
            teacherButton.translatesAutoresizingMaskIntoConstraints = false
            teacherButton.titleLabel?.adjustsFontSizeToFitWidth = true
            staffButtons[teacherButton] = c
            listingContainer.addSubview(teacherButton)
            teacherButton.leftAnchor.constraint(equalTo: periodLabel.rightAnchor, constant: 5).isActive = true
            teacherButton.rightAnchor.constraint(equalTo: listingContainer.rightAnchor, constant: -5).isActive = true
            teacherButton.centerYAnchor.constraint(equalTo: listingContainer.centerYAnchor).isActive = true
            let data = DataHolder()
            data.data["Teacher"] = c.staff.name;
            teacherButton.addSubview(data)
            teacherButton.addTarget(self, action: #selector(teacherButtonClick(sender:)), for: .touchUpInside)
            
            if fullySorted.last?.id != c.id {
                let seperator = UIView()
                seperator.backgroundColor = UIColor.lightGray
                seperator.translatesAutoresizingMaskIntoConstraints = false
                
                listingContainer.addSubview(seperator)
                seperator.bottomAnchor.constraint(equalTo: listingContainer.bottomAnchor).isActive = true
                seperator.leftAnchor.constraint(equalTo: listingContainer.leftAnchor).isActive = true
                seperator.rightAnchor.constraint(equalTo: listingContainer.rightAnchor).isActive = true
                seperator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            }
            
            
            scheduleBackground.addSubview(listingContainer)
            listingContainer.topAnchor.constraint(equalTo: (fullySorted.first!.id == c.id) ? lastView.topAnchor : lastView.bottomAnchor).isActive = true
            listingContainer.leftAnchor.constraint(equalTo: scheduleBackground.leftAnchor).isActive = true
            listingContainer.rightAnchor.constraint(equalTo: scheduleBackground.rightAnchor).isActive = true
            listingContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            lastView = listingContainer
            
        }
        
    }
    
    @objc
    func teacherButtonClick(sender:UIButton){
        var teacherName:String = ""
        for sub in sender.subviews {
            if let dataHolder = sub as? DataHolder {
                if let teacher = dataHolder.data["Teacher"] as? String {
                    teacherName = teacher
                    break
                }
            }
        }
        let staffCont = StaffInfoController(name: teacherName)
        navigationController?.pushViewController(staffCont, animated: true)
    }
    
    @objc
    func changeTableDisplay(sender:UISegmentedControl){
        for btn in staffButtons.keys{
            if let c = staffButtons[btn]{
                if sender.selectedSegmentIndex == 0{
                    btn.setTitle(c.staff.name, for: .normal)
                }
                else{
                    btn.setTitle(c.name, for: .normal)
                }
            }
        }
    }
    
    @objc
    func navigateButton(_ sender:UIButton){
        
//        var otherController:UIViewController? = nil
        if let cont = ScheduleController.sharedInstance {
//            otherController = cont
            NotificationCenter.default.post(name: Notification.Name("Dismiss All"), object: nil)
        }
        else if let cont = StaffSearchController.sharedInstance {
//            otherController = cont
            NotificationCenter.default.post(name: Notification.Name("Dismiss All"), object: nil)
            
        }
        
//        if let s = otherController {
//            s.dismiss(animated: true, completion: nil)
//            s.dismiss(animated: true) {
//                switch sender.tag {
//                case 0:
//                    //From
//                    OverlayController.sharedInstance.roomSelected(name: self.title!, pos: .From)
//                    break
//                case 1:
//                    //To
//                    OverlayController.sharedInstance.roomSelected(name: self.title!, pos: .To)
//                    break
//                default:
//                    break
//                }
//            }
//            return
//        }
        switch sender.tag {
        case 0:
            //From
            OverlayController.sharedInstance.roomSelected(name: title!, pos: .From)
            break
        case 1:
            //To
            OverlayController.sharedInstance.roomSelected(name: title!, pos: .To)
            break
        default:
            break
        }
        
    }
    
    

}
