//
//  Staff.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Staff{
    let name:String
    var phoneNum:String!
    var email:String!
    var department:String!
    var classIds:[String] = []
    var classes:[Class] = []
    init(_ name:String) {
        self.name = name
    }
    
    static func load() -> (staff:[Staff], classes:[Class]){
        var data:(staff:[Staff], classes:[Class]) = loadFromCoreData()
        if data.staff.count == 0 {
            print("No Staff Data found in Core Data Attempting to load from fallback")
            data = loadFromJSON()
            print("Loaded From Fallback. Attempting Save to Core Data")
            save(staff: data.staff)
        }else{
            print("Staff Data Loaded From Core Data")
        }
        return data
    }
    static fileprivate func loadFromCoreData() -> (staff:[Staff], classes:[Class]){
        var staffCD:[StaffPerson] = []
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StaffPerson")
        request.returnsObjectsAsFaults = false
        do{
            let result = (try context.fetch(request)) as! [StaffPerson]
            staffCD = result
        }catch{
            print("Core Data Staff Fetch Failed")
        }
        var allStaff:[Staff] = []
        var allClasses:[Class] = []
        for staff in staffCD {
            guard let name = staff.name else {continue}
            guard let phone = staff.phone else {continue}
            guard let email = staff.email else {continue}
            guard let department = staff.department else {continue}
            guard let cs = staff.classes?.array as? [StaffClass] else{continue}
            
            let s = Staff(name)
            s.phoneNum = phone
            s.email = email
            s.department = department
            
            var classes:[Class] = []
            var classIDs:[String] = []
            for c in cs {
                guard let cname = c.name else{continue}
                guard let id = c.id else{continue}
                guard let period = c.period else{continue}
                guard let location = c.location else{continue}
                
                let c1 = Class(cname)
                c1.id = id
                c1.period = period
                c1.location = location
                classes.append(c1)
                classIDs.append(id)
            }
            s.classes = classes
            s.classIds = classIDs
            allStaff.append(s)
            allClasses.append(contentsOf: classes)
        }
        return (staff: allStaff, classes: allClasses)
    }
    static fileprivate func loadFromJSON(jsonString:String = "fallback") -> (staff:[Staff], classes:[Class]){
        return StaffParser.parseStaff(jsonString)
    }
    static func save(staff:[Staff]) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
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
            print("Core Data Staff Fetch & Delete Failed")
            print("Canceling Save due to possible data duplication")
            return
        }
        
        
        for s in staff {
            let sp = StaffPerson(context: context)
            sp.name = s.name
            sp.email = s.email
            sp.phone = s.phoneNum
            sp.department = s.department
            for c in s.classes {
                let sc = StaffClass(context: context)
                sc.id = c.id
                sc.name = c.name
                sc.period = c.period
                sc.location = c.location
                sp.addToClasses(sc)
            }
        }
        do{
            try context.save()
            print("Saved Staff Data to CoreData")
        }catch {
            print("Failed To Save Staff Data To Core Data")
        }
    }
    static func save(jsonString:String){
        let data = StaffParser.parseStaff(jsonString)
        save(staff: data.staff)
    }
}
