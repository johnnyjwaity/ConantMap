//
//  Schedule.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import UIKit

class Schedule{
    
    
    var classes:[Class]!
    var semClasses:[[Class]] = [[],[]]
    
    init(_ schedule:String) {
        print(schedule)
        self.classes = parseSchedule(schedule)
    }
    init(_ schedule:SimpleSchedule) {
        classes = []
        for c in schedule.classes {
            let cl = Class(period: c.period)
            cl.name = c.name
            cl.semester = c.semester
            cl.location = c.location
            for s in Global.staff {
                if s.name == c.staff.name {
                    cl.potentialStaff = s
                    print("Found \(c.staff.name)")
                    break
                }
            }
            semClasses[c.semester - 1].append(cl)
            classes.append(cl)
        }
    }
    
    func getClass(period:String, semester:Int) -> Class?{
        for c in classes {
            if c.period == period && c.semester == semester {
                return c
            }
        }
        return nil
    }
    
    func parseSchedule(_ schedule:String) -> [Class]{
        let semesters = schedule.components(separatedBy: "S2,")
        
        var semesterIndex = 1
        var allClasses:[Class] = []
        for semester in semesters {
            let classes = semester.components(separatedBy: ",")
            var index = 0
            var currentClass:Class!
            for c in classes {
                if index == 0 {
                    //Period
                    var p = c;
                    if p.first == "0"{
                        p.removeFirst()
                    }
                    currentClass = Class(period: p)
                    currentClass.semester = semesterIndex
                    
                }else if index == 1{
                    //Class Name
                    currentClass.name = c
                }else if index == 2 {
                    //Room Number
                    var roomName = c
                    if roomName.lowercased().contains("caf") {
                        roomName = "Cafeteria"
                    }
                    for room in Global.rooms {
                        if room.lowercased() == roomName.lowercased() {
                            currentClass.location = room
                            break
                        }
                    }
                    
                }else {
                    //Teacher
                    for s in Global.staff {
                        if s.name.contains(c){
                            currentClass.potentialStaff = s
                            break
                        }
                    }
                    if currentClass.name != "EMPTY" {
                        allClasses.append(currentClass)
                        semClasses[semesterIndex - 1].append(currentClass)
                    }
                    
                }
                index += 1
                if index == 4 {
                    index = 0
                }
            }
            semesterIndex += 1
        }
        return allClasses
    }
    
    struct SimpleSchedule: Codable {
        let classes:[SimpleClass]
    }
    struct SimpleClass: Codable {
        let name:String
        let location:String
        let period:String
        let semester:Int
        let staff:SimpleStaff
        
    }
    struct SimpleStaff:Codable {
        let name:String
        
    }
    
    func save(){
        let s = convertToSimpleSchedule()
        let data = try? JSONEncoder().encode(s)
        if let d = data {
            UserDefaults.standard.set(d, forKey: "schedule")
        }
    }
    func convertToSimpleSchedule() -> SimpleSchedule {
        var simpleClasses:[SimpleClass] = []
        for c in classes {
            var staffName = ""
            if let staff = c.potentialStaff {
                staffName = staff.name
            }
            simpleClasses.append(SimpleClass(name: c.name, location: c.location, period: c.period, semester: c.semester, staff: SimpleStaff(name: staffName)))
            
        }
        return SimpleSchedule(classes: simpleClasses)
    }
}


