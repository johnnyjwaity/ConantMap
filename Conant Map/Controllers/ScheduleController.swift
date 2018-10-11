//
//  ScheduleController.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class ScheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var schedule:Schedule!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        // Do any additional setup after loading the view.
    }
    
    func setup(){
        let scheduleStr = "EB,EMPTY,None,01,Spanish 3,228,02,AP Language and Composition,120,03,Trigonometry Calculus A,243,04,PE 3 & 4,GYM,05,Advanced Placement Physics,285,06,Advanced Placement Physics,285,07,Mobile Application Development,221,08,AP United States History,237,S2,EB,EMPTY,None,01,Spanish 3,228,02,AP Language and Composition,120,03,Trigonometry Calculus A,243,04,PE 3 & 4,GYM,05,Advanced Placement Physics,285,06,Advanced Placement Physics,285,07,Mobile Application Development,221,08,AP United States History,237,"
        
        
        schedule = Schedule(scheduleStr)
        navigationController?.title = "Schedule"
        
        let semesterControl = UISegmentedControl(items: ["Semester 1", "Semester 2"])
        semesterControl.translatesAutoresizingMaskIntoConstraints = false
        semesterControl.selectedSegmentIndex = 0
        view.addSubview(semesterControl)
        semesterControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        semesterControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        semesterControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        
        
        
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 239/255)
        tableView.layer.cornerRadius = 8
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: semesterControl.bottomAnchor, constant: 10).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        view.backgroundColor = UIColor.white
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return ScheduleCell()
    }
    

}
