//
//  Schedule.swift
//  Conant Map
//
//  Created by Johnny Waity on 10/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

class Schedule {
    
    var classes:[Class]!
    
    init(_ schedule:String) {
        self.classes = parseSchedule(schedule)
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
                if index % 3 == 0 {
                    //Period
                    currentClass = Class(period: c)
                    currentClass.semester = semesterIndex
                    
                }else if index % 2 == 0{
                    //Class Name
                    currentClass.name = c
                }else {
                    //Room Number
                    currentClass.location = c
                    allClasses.append(currentClass)
                    
                    for staff in Global.staff {
                        for c in staff.classes {
//                            if c.period =
                        }
                    }
                    
                }
                index += 1
            }
            semesterIndex += 1
        }
        return allClasses
    }
    
    
    
}
