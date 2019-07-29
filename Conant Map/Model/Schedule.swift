//
//  Schedule.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Schedule{
    
    
    var classes:[Class]!
    var semClasses:[[Class]] = [[],[]]
    
    init(_ schedule:SimpleSchedule) {
        var sortedClasses = schedule.classes
        sortedClasses.sort { (c1, c2) -> Bool in
            if c1.period == "EB" {
                return true
            }
            if c2.period == "EB" {
                return false
            }
            if c1.period == "AC" {
                return false
            }
            if c2.period == "AC" {
                return true
            }
            
            let p1 = Int(c1.period)!
            let p2 = Int(c2.period)!
            
            if p1 < p2 {
                return true
            }
            return false
        }
        classes = []
        for c in sortedClasses {
            let cl = Class(period: c.period)
            cl.name = c.name
            cl.semester = c.semester
            cl.location = c.location
            if c.staff.name != "-" {
                for s in Global.staff {
                    if s.name.contains(c.staff.name) || c.staff.name.contains(s.name) {
                        if cl.potentialStaff != nil {
                            if s.name == c.staff.name {
                                cl.potentialStaff = s
                            }
                        }else{
                            cl.potentialStaff = s
                        }
                    }
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
    
    
    func save(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        for c in classes {
            let entity = NSEntityDescription.entity(forEntityName: "ScheduleClass", in: context)
            let newClass = NSManagedObject(entity: entity!, insertInto: context)
            newClass.setValue(c.name, forKey: "name")
            newClass.setValue(c.period, forKey: "period")
            newClass.setValue(c.location, forKey: "room")
            newClass.setValue(c.semester, forKey: "semester")
            newClass.setValue(c.potentialStaff?.name ?? "", forKey: "teacher")
        }
        do{
            try context.save()
            print("Saved record")
        }catch {
            print("Couldnt save record")
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
