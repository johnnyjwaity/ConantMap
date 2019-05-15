//
//  StaffInfoController.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/29/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit
import MessageUI

class StaffInfoController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let name:String
    var staff:Staff!
    var infoSelector:UISegmentedControl!
    init(name:String) {
        self.name = name;
        super.init(nibName: nil, bundle: nil)
        title = name
    }
    
    var classLabels:[UIButton:Class] = [:]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not Suppoted")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIScrollView()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        for s in Global.staff {
            if s.name.lowercased() == name.lowercased() {
                staff = s;
                break
            }
        }
        
        
        
        var sorted:[String:[Class]] = [:]
        for c in staff.classes {
            print(c.name)
            print(c.period)
            print(c.location)
            if let pList = sorted[c.period]{
                var isDuplicate = false
                for c1 in pList{
                    if(c.period == c1.period && c.staff.name == c1.staff.name && c.period != "AC"){
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
        if let eb = sorted["EB"]{
            fullySorted.append(contentsOf: eb)
        }
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
        scroll.backgroundColor = UIColor.white
        scroll.contentSize = CGSize(width: view.bounds.width, height: CGFloat(50 * fullySorted.count + 300))
        
        let infoBackground = UIView()
        infoBackground.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        infoBackground.layer.cornerRadius = 8
        infoBackground.translatesAutoresizingMaskIntoConstraints = false
        infoBackground.clipsToBounds = true
        view.addSubview(infoBackground)
        infoBackground.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        infoBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        infoBackground.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let emailLabel = UILabel()
        emailLabel.text = "Email:"
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.textColor = UIColor.lightGray
        infoBackground.addSubview(emailLabel)
        emailLabel.topAnchor.constraint(equalTo: infoBackground.topAnchor).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: infoBackground.heightAnchor, multiplier: 0.5).isActive = true
        emailLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: infoBackground.leftAnchor, constant: 10).isActive = true
        
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        infoBackground.addSubview(divider)
        divider.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        divider.leftAnchor.constraint(equalTo: infoBackground.leftAnchor).isActive = true
        divider.rightAnchor.constraint(equalTo: infoBackground.rightAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        let phoneLabel = UILabel()
        phoneLabel.text = "Phone:"
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.textColor = UIColor.lightGray
        infoBackground.addSubview(phoneLabel)
        phoneLabel.topAnchor.constraint(equalTo: divider.topAnchor).isActive = true
        phoneLabel.heightAnchor.constraint(equalTo: infoBackground.heightAnchor, multiplier: 0.5).isActive = true
        phoneLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        phoneLabel.leftAnchor.constraint(equalTo: infoBackground.leftAnchor, constant: 10).isActive = true
        
        let emailAddress = UIButton(type: .system)
        emailAddress.setTitle(staff.email, for: .normal)
        emailAddress.translatesAutoresizingMaskIntoConstraints = false
        emailAddress.titleLabel?.adjustsFontSizeToFitWidth = true
        infoBackground.addSubview(emailAddress)
        emailAddress.leftAnchor.constraint(equalTo: emailLabel.rightAnchor).isActive = true
        emailAddress.rightAnchor.constraint(equalTo: infoBackground.rightAnchor, constant: -8).isActive = true
        emailAddress.bottomAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
        emailAddress.topAnchor.constraint(equalTo: infoBackground.topAnchor).isActive = true
        emailAddress.addTarget(self, action: #selector(sendEmail(_:)), for: .touchUpInside)
        
        let phoneNumber = UIButton(type: .system)
        phoneNumber.setTitle(staff.phoneNum, for: .normal)
        phoneNumber.translatesAutoresizingMaskIntoConstraints = false
        phoneNumber.titleLabel?.adjustsFontSizeToFitWidth = true
        infoBackground.addSubview(phoneNumber)
        phoneNumber.leftAnchor.constraint(equalTo: phoneLabel.rightAnchor).isActive = true
        phoneNumber.rightAnchor.constraint(equalTo: infoBackground.rightAnchor, constant: -8).isActive = true
        phoneNumber.bottomAnchor.constraint(equalTo: infoBackground.bottomAnchor).isActive = true
        phoneNumber.topAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
        
        let departmentBackground = UIView()
        departmentBackground.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        departmentBackground.layer.cornerRadius = 8
        departmentBackground.translatesAutoresizingMaskIntoConstraints = false
        departmentBackground.clipsToBounds = true
        view.addSubview(departmentBackground)
        departmentBackground.topAnchor.constraint(equalTo: infoBackground.bottomAnchor, constant: 20).isActive = true
        departmentBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        departmentBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        departmentBackground.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let departmentLabel = UILabel()
        departmentLabel.text = "Department:"
        departmentLabel.translatesAutoresizingMaskIntoConstraints = false
        departmentLabel.textColor = UIColor.lightGray
        departmentBackground.addSubview(departmentLabel)
        departmentLabel.centerYAnchor.constraint(equalTo: departmentBackground.centerYAnchor).isActive = true
        departmentLabel.heightAnchor.constraint(equalTo: departmentBackground.heightAnchor, multiplier: 0.5).isActive = true
        departmentLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        departmentLabel.leftAnchor.constraint(equalTo: departmentBackground.leftAnchor, constant: 10).isActive = true
        
        let department = UIButton(type: .system)
        department.setTitle((staff.department.contains("English") ? "English" : staff.department), for: .normal)
        department.translatesAutoresizingMaskIntoConstraints = false
        department.titleLabel?.adjustsFontSizeToFitWidth = true
        departmentBackground.addSubview(department)
        department.leftAnchor.constraint(equalTo: departmentLabel.rightAnchor).isActive = true
        department.rightAnchor.constraint(equalTo: departmentBackground.rightAnchor, constant: -8).isActive = true
        department.bottomAnchor.constraint(equalTo: departmentBackground.bottomAnchor).isActive = true
        department.centerYAnchor.constraint(equalTo: departmentBackground.centerYAnchor).isActive = true
        department.addTarget(self, action: #selector(departmentButtonClicked), for: .touchUpInside)
        
        
        if fullySorted.count != 0 {
            infoSelector = UISegmentedControl(items: ["Location", "Class Name"])
            infoSelector.selectedSegmentIndex = 0
            infoSelector.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(infoSelector)
            infoSelector.topAnchor.constraint(equalTo: departmentBackground.bottomAnchor, constant: 20).isActive = true
            infoSelector.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
            infoSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            infoSelector.addTarget(self, action: #selector(changeTableDisplay(sender:)), for: .valueChanged)
            
            let scheduleBackground = UIView()
            scheduleBackground.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
            scheduleBackground.translatesAutoresizingMaskIntoConstraints = false
            scheduleBackground.layer.cornerRadius = 8
            scheduleBackground.clipsToBounds = true
            view.addSubview(scheduleBackground)
            scheduleBackground.topAnchor.constraint(equalTo: infoSelector.bottomAnchor, constant: 10).isActive = true
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
                
                
                
                let roomButton = UIButton(type: .system)
                roomButton.setTitle((c.location != "") ? c.location : "No Location Available", for: .normal)
                roomButton.translatesAutoresizingMaskIntoConstraints = false
                roomButton.titleLabel?.adjustsFontSizeToFitWidth = true
                
                listingContainer.addSubview(roomButton)
                roomButton.leftAnchor.constraint(equalTo: periodLabel.rightAnchor, constant: 5).isActive = true
                roomButton.rightAnchor.constraint(equalTo: listingContainer.rightAnchor, constant: -5).isActive = true
                roomButton.centerYAnchor.constraint(equalTo: listingContainer.centerYAnchor).isActive = true
                let data = DataHolder()
                data.data["Room"] = c.location;
                roomButton.addSubview(data)
                roomButton.addTarget(self, action: #selector(roomButtonClicked(sender:)), for: .touchUpInside)
                
                classLabels[roomButton] = c
                
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
        }else{
            let label = UILabel()
            label.textColor = UIColor.lightGray
            label.text = "No Schedule Information Available"
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            view.addSubview(label)
            label.topAnchor.constraint(equalTo: departmentBackground.bottomAnchor, constant: 20).isActive = true
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
    }
    
    @objc
    func departmentButtonClicked(){
        changeToRoomPage(Global.departments[staff.department]!)
    }

    @objc
    func roomButtonClicked(sender:UIButton){
        if infoSelector.selectedSegmentIndex == 1 {
            return
        }
        changeToRoomPage((classLabels[sender]?.location)!)
    }
    func changeToRoomPage(_ name:String){
        navigationController?.pushViewController(RoomInfoController(room: name), animated: true)
    }
    
    @objc
    func changeTableDisplay(sender:UISegmentedControl){
        for btn:UIButton in classLabels.keys{
            if let c = classLabels[btn]{
                if(sender.selectedSegmentIndex == 0){
                    btn.setTitle(c.location, for: .normal)
                    if c.location == "" {
                        btn.setTitle("No Location Available", for: .normal)
                    }
                }
                else{
                    btn.setTitle(c.name, for: .normal)
                }
            }
        }
    }
    
    @objc
    func sendEmail(_ sender:UIButton){
        let eCont = MFMailComposeViewController()
        eCont.mailComposeDelegate = self
        eCont.setToRecipients([(sender.titleLabel?.text)!])
        present(eCont, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
