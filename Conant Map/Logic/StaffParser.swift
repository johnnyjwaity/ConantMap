//
//  StaffParser.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

class StaffParser{
    static func parseStaff(_ file:String) -> (staff:[Staff], classes:[Class]){
        //Prepare Array For Staff
        var staff:[Staff] = []
        var classes:[Class] = []
        
        var jsonString = file
        
        if file == "fallback" {
            do{
                //Get File Path
                let path = Bundle.main.path(forResource: "staff", ofType: "json")
                //String from File
                let rawString = try String(contentsOfFile: path!)
                jsonString = rawString
            }catch{
                print(error)
            }
        }
        jsonString = jsonString.replacingOccurrences(of: "&amp;", with: "&")
        var jsonStaff:[JSONStaff] = []
        do {
            jsonStaff = try JSONDecoder().decode([JSONStaff].self, from: jsonString.data(using: .utf8)!)
        }catch{
            print("Decode Error")
            print(error.localizedDescription)
        }
        for js in jsonStaff {
            let s = Staff(js.name)
            s.email = js.email
            s.phoneNum = js.phone
            s.department = js.department
            
            var c:[Class] = []
            var cid:[String] = []
            for jc in js.classes {
                let cc = Class(jc.name)
                cc.id = jc.id
                cc.location = jc.location
                cc.period = jc.period
                cc.staff = s
                c.append(cc)
                cid.append(cc.id)
            }
            
            s.classes = c
            s.classIds = cid
            staff.append(s)
            classes.append(contentsOf: c)
        }
        return (staff:staff, classes:classes)
    }
    
    func createJSONData(){
        var staffs:[JSONStaff] = []
        for s in Global.staff {
            var classes:[JSONClass] = []
            for c in s.classes {
                let jc = JSONClass(id: c.id, name: c.name, period: c.period, location: c.location)
                classes.append(jc)
            }
            let js = JSONStaff(name: s.name, email: s.email, phone: s.phoneNum, department: s.department, classes: classes)
            staffs.append(js)
        }
        do{
            let jsonData = try JSONEncoder().encode(staffs)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            //            print(jsonString)
            
            let fileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("staff.json")
            do{
                try jsonString.write(to: fileName, atomically: true, encoding: .utf8)
                print("Saved to \(fileName.absoluteString)")
            }catch {
                print("Write Error")
            }
        }catch{
            print("Encode Error")
        }
    }
}

struct JSONClass:Codable {
    let id:String
    let name:String
    let period:String
    let location:String
}
struct JSONStaff:Codable {
    let name:String
    let email:String
    let phone:String
    let department:String
    var classes:[JSONClass]
}
