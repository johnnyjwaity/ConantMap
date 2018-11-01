//
//  SettingsController.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/31/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let fields:[[String]] = [["Display Room Labels"], ["Created By John Waity", "Report a Bug"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        view.backgroundColor = UIColor.white
        title = "Settings"
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restoreDefaults))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeSettings))
        
        
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General"
        case 1:
            return "About"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SwitchCell")
        cell.textLabel?.text = fields[indexPath.section][indexPath.row]
        if indexPath.section == 0 && indexPath.row == 0 {
            let s = UISwitch(frame: CGRect.zero)
            s.isOn = UserDefaults.standard.bool(forKey: "displayRoomLabels")
            s.addTarget(self, action: #selector(toggleRoomLabels(_:)), for: .valueChanged)
            cell.accessoryView = s
        }
        else if indexPath.section == 1 {
            cell.textLabel?.textColor = UIView().tintColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0{
            guard let url = URL(string: "https://johnnywaity.com") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else if indexPath.section == 1 && indexPath.row == 1 {
            //Open Bug Reporter
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc
    func closeSettings(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func toggleRoomLabels(_ sender:UISwitch){
        UserDefaults.standard.set(sender.isOn, forKey: "displayRoomLabels")
        NotificationCenter.default.post(name: Notification.Name("ChangeRoomLabelDispaly"), object: nil)
    }

}
