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
            save(staff: data.staff, version: 0)
        }else{
            print("Staff Data Loaded From Core Data. Version: \(UserDefaults.standard.integer(forKey: "Staff-Version"))")
        }
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            Staff.updateFromNetwork()
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
                c1.staff = s
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
    static func save(staff:[Staff], version:Int) {
//        var appDelegate:AppDelegate? = nil
//        if Thread.isMainThread {
//            appDelegate = (UIApplication.shared.delegate as! AppDelegate)
//        }else{
//            DispatchQueue.main.sync {
//                appDelegate = (UIApplication.shared.delegate as! AppDelegate)
//            }
//        }
        DispatchQueue.main.async {
            let delegate = (UIApplication.shared.delegate as! AppDelegate)
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
                UserDefaults.standard.set(version, forKey: "Staff-Version")
                print("Saved Staff Data to CoreData. Version: \(version)")
            }catch {
                print("Failed To Save Staff Data To Core Data")
            }
        }
        
    }
    static func save(jsonString:String, version:Int){
        let data = StaffParser.parseStaff(jsonString)
        save(staff: data.staff, version: version)
    }
    
    static func updateFromNetwork(){
        let version = UserDefaults.standard.integer(forKey: "Staff-Version")
        var request = URLRequest(url: URL(string: "https://api.conantmap.com/data?version=\(version)&data=staff")!)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession.init(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            if let res = response as? HTTPURLResponse {
                if let updateHeaderValue = res.allHeaderFields["Update"] as? String {
                    let shouldUpdate = updateHeaderValue == "1" ? true : false
                    if shouldUpdate {
                        if let versionHeaderValue = res.allHeaderFields["Version"] as? String {
                            let newVersion = Int(versionHeaderValue)
                            if let v = newVersion {
                                if v > version {
                                    print("Updating Data From Network")
                                    if let d = data {
                                        let jsonStringParse = String(data: d, encoding: .utf8)
                                        if var jsonString = jsonStringParse {
                                            jsonString = jsonString.replacingOccurrences(of: "\\", with: "")
                                            
                                            print(jsonString)
                                            save(jsonString: jsonString, version: v)
                                        }
                                    }else{
                                        print("No Data")
                                    }
                                }
                            }
                        }
                    }
                }else{
                    print("No Update Header")
                }
            }
        }
        task.resume()
    }
}
