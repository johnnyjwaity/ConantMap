//
//  ScheduleController.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class ScheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleImportDelegate {
    
    
    static var sharedInstance:ScheduleController?
    
    
    var schedule:Schedule?
    var currentSemester = 0
    var tableView:UITableView!
    var tableHeightConstriant:NSLayoutConstraint!
    var semesterControl:UISegmentedControl!
    var importButton:UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ScheduleController.sharedInstance = self
        setup()

        // Do any additional setup after loading the view.
    }
    
    func setup(){
        
        let month = Calendar.current.component(.month, from: Date())
        currentSemester = (month < 6) ? 1 : 0
        
        if let data = UserDefaults.standard.data(forKey: "schedule") {
            let decodeData = try? JSONDecoder().decode(Schedule.SimpleSchedule.self, from: data)
            if let simpleSchedule = decodeData {
                schedule = Schedule(simpleSchedule)
            }
        }
        
        
        
        title = "Schedule"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSchedule))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSchedule))
        
        importButton = UIButton(type: .system)
        importButton.setTitle("Import Schedule", for: .normal)
        importButton.translatesAutoresizingMaskIntoConstraints = false
        importButton.backgroundColor = UIView().tintColor
        importButton.setTitleColor(UIColor.white, for: .normal)
        importButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        importButton.layer.cornerRadius = 8
        view.addSubview(importButton)
        importButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        importButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        importButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        importButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        if schedule != nil {
            importButton.alpha = 0
            importButton.isEnabled = false
        }
        importButton.addTarget(self, action: #selector(startImport), for: .touchUpInside)
        
        
        
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        tableView.layer.cornerRadius = 8
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(tableView)
        
        semesterControl = UISegmentedControl(items: ["Semester 1", "Semester 2"])
        semesterControl.translatesAutoresizingMaskIntoConstraints = false
        semesterControl.selectedSegmentIndex = currentSemester
        if schedule == nil {
            semesterControl.alpha = 0
        }
        view.addSubview(semesterControl)
        semesterControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        semesterControl.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -20).isActive = true
        semesterControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        semesterControl.addTarget(self, action: #selector(changeSemester(_:)), for: .valueChanged)
        
        
        
        
        
        
        
//        tableView.topAnchor.constraint(equalTo: semesterControl.bottomAnchor, constant: 10).isActive = true
        var numOfRows = 0
        if let s = schedule {
            numOfRows = s.semClasses[semesterControl.selectedSegmentIndex].count
        }
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        tableHeightConstriant = tableView.heightAnchor.constraint(equalToConstant: CGFloat(50 * numOfRows))
        tableHeightConstriant.isActive = true
        view.backgroundColor = UIColor.white
        
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "cell")
        

        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = schedule {
            return s.semClasses[semesterControl.selectedSegmentIndex].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ScheduleCell
        cell.setInfo(schedule!.semClasses[currentSemester][indexPath.row])
        
        cell.teacherButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.roomButton.removeTarget(nil, action: nil, for: .allEvents)
        
        cell.teacherButton.addTarget(self, action: #selector(startSearch(_:)), for: .touchUpInside)
        cell.roomButton.addTarget(self, action: #selector(startSearch(_:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func displayScheudle(_ schedule: Schedule?) {
        self.schedule = schedule
        updateTableHeight()
        tableView.reloadData()
    }
    
    @objc
    func changeSemester(_ sender:UISegmentedControl){
        currentSemester = sender.selectedSegmentIndex//(currentSemester == 0) ? 1 : 0
        updateTableHeight()
        tableView.reloadData()
    }
    
    func updateTableHeight(){
        var newHeight:CGFloat = 0
        if let s = schedule {
            newHeight = CGFloat(50 * s.semClasses[semesterControl.selectedSegmentIndex].count)
            semesterControl.alpha = 1
            importButton.alpha = 0
            importButton.isEnabled = false
        }else{
            semesterControl.alpha = 0
            importButton.alpha = 1
            importButton.isEnabled = true
        }
        tableHeightConstriant.constant = newHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    func startImport(){
        let importController = ScheduleImportController()
        importController.delegate = self
        importController.modalPresentationStyle = .currentContext
        present(importController, animated: true, completion: nil)
    }
    
    @objc
    func deleteSchedule(){
        let actionSheet = UIAlertController(title: "Delete Schedule", message: "Are You Sure?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            UserDefaults.standard.removeObject(forKey: "schedule")
            self.displayScheudle(nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    @objc
    func dismissSchedule(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func startSearch(_ button:UIButton) {
        var viewCont:UIViewController?
        switch button.tag {
        case 0:
            //Teacher
            viewCont = StaffInfoController(name: (button.titleLabel?.text)!)
            break
        case 1:
            //Room
            viewCont = RoomInfoController(room: (button.titleLabel?.text)!)
            break
        default:
            break
        }
        if viewCont == nil {
            return
        }
        let placeHolder = UIViewController()
        placeHolder.title = "Schedule"
        let search = SearchNavigationController(rootViewController: placeHolder)
        search.modalPresentationStyle = .currentContext
        search.pushViewController(viewCont!, animated: false)
        present(search, animated: true, completion: nil)
    }
    
    

}
