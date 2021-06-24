//
//  SettingsController.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/31/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit
import CoreData

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let fields:[[String]] = [["Display Room Labels", "Current Location", "Delete All Data"], ["Created By John Waity", "Version"]]

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
        return 2
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
        return fields[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SwitchCell")
        cell.textLabel?.text = fields[indexPath.section][indexPath.row]
        if indexPath.section == 0 && indexPath.row == 0 {
            let s = UISwitch(frame: CGRect.zero)
            s.isOn = UserDefaults.standard.bool(forKey: "displayRoomLabels")
            if UserDefaults.standard.object(forKey: "displayRoomLabels") == nil {
                s.isOn = true
            }
            s.addTarget(self, action: #selector(toggleRoomLabels(_:)), for: .valueChanged)
            cell.accessoryView = s
        }else if indexPath.section == 0 && indexPath.row == 1 {
            let segment = UISegmentedControl(items: ["Off", "Hybrid", "GPS", "MAC"])
            segment.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "location")
            cell.accessoryView = segment
            segment.addTarget(self, action: #selector(changeLocationType(_:)), for: .valueChanged)
        }else if indexPath.section == 0 && indexPath.row == 2 {
            cell.textLabel?.textColor = UIColor.red
        }else if indexPath.section == 1 && indexPath.row == 0 {
            cell.textLabel?.textColor = UIView().tintColor
        }else if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel?.textColor = UIView().tintColor
            cell.textLabel?.text = "Version \((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "??")"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0{
            guard let url = URL(string: "https://johnnywaity.com") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else if indexPath.section == 0 && indexPath.row == 2 {
            //Delete All Data
            let alert = UIAlertController(title: "Are You Sure?", message: "This will remove all schedule data saved.", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                self.deleteAllData()
                let a2 = UIAlertController(title: "Deleted All Data", message: nil, preferredStyle: .alert)
                a2.addAction(UIAlertAction(title: "Ok!", style: .default, handler: nil))
                self.present(a2, animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(delete)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
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
    @objc
    func changeLocationType(_ sender:UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "location")
        NotificationCenter.default.post(name: Notification.Name("ChangeLocationType"), object: nil)
    }
    
    func deleteAllData(){
        var appDelegate:AppDelegate? = nil
        if Thread.isMainThread {
            appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        }else{
            DispatchQueue.main.sync {
                appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            }
        }
        guard let delegate = appDelegate else {print("No Delegate"); return}
        let context = delegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StaffPerson")
        request.returnsObjectsAsFaults = false
        do{
            let result = (try context.fetch(request)) as! [StaffPerson]
            for person in result {
                if let staffclasses = person.classes?.array as? [StaffClass] {
                    for staffclass in staffclasses {
                        context.delete(staffclass)
                    }
                }
                context.delete(person)
            }
            try context.save()
            print("Old Staff Data Deleted")
        }catch{
            print("Core Data Staff Delete Failed")
        }
        
        let scheduleRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleClass")
        scheduleRequest.returnsObjectsAsFaults = false
        do{
            let result = (try context.fetch(request)) as! [ScheduleClass]
            for sc in result {
                
                context.delete(sc)
            }
            try context.save()
        }catch {
            print("Schedule Delete Failed")
        }
    }
}
