//
//  Network.swift
//  Conant Map
//
//  Created by Johnny Waity on 7/21/19.
//  Copyright © 2019 Johnny Waity. All rights reserved.
//

import Foundation

class Network {
    static func getSchedule(firstName:String, lastName:String, birthday:Date, id:String, completionHandler: @escaping (_ result:SimpleSchedule?, _ error:String?) -> Void) {
        
        var username = id
        if username.count == 6 {
            username = "000" + username
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMddyy")
        var dateString = dateFormatter.string(from: birthday)
        dateString = dateString.replacingOccurrences(of: "/", with: "")
        let password = "\(firstName.lowercased().first!)\(lastName.lowercased().first!)\(dateString)"
        
        print(password)
        
        var request = URLRequest(url: URL(string: "https://api.conantmap.com/schedule")!)
        request.httpMethod = "POST"
        
        let data = ["username":username, "password":password]
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
        
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("Requesting")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("Recieved response")
            if let e = error {
                print(e)
                completionHandler(nil, "Could Not Connect To Server. Please check your internet connection.")
                return
            }
            if let d = data {
                let json = try! JSONSerialization.jsonObject(with: d, options: []) as! [String:Any]
                if let success = json["success"] as? Bool {
                    if success {
                        if let schedule = json["schedule"] as? [String:[[String:String]]] {
                            var semsters:[String] = []
                            for key in schedule.keys {
                                semsters.append(key)
                            }
                            semsters.sort()
                            var classes:[SimpleClass] = []
                            for i in 0..<semsters.count {
                                let semesterNum = i + 1
                                for c in schedule[semsters[i]]! {
                                    guard let className = c["className"] else{continue}
                                    guard let period = c["period"] else{continue}
                                    let teacher = c["teacher"] ?? "-"
                                    let room = c["roomName"] ?? "-"
                                    let simpleClass = SimpleClass(name: className, location: room, period: period, semester: semesterNum, staff: SimpleStaff(name: teacher))
                                    classes.append(simpleClass)
                                }
                            }
                            let simpleSchedule = SimpleSchedule(classes: classes)
                            completionHandler(simpleSchedule, nil)
                            return
                        }
                    }else{
//                        let classes = [SimpleClass(name: "English", location: "221", period: "02", semester: 1, staff: SimpleStaff(name: "Garbage Man")),
//                                       SimpleClass(name: "English", location: "221", period: "04", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "06", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "03", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "05", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "01", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "08", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "07", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "EB", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "AC", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "AC", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "AC", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "AC", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "AC", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "English", location: "221", period: "AC", semester: 1, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "02", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "04", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "06", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "03", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "05", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "01", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "08", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "07", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "EB", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "AC", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "AC", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "AC", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "AC", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "AC", semester: 2, staff: SimpleStaff(name: "-")),
//                                       SimpleClass(name: "Science", location: "221", period: "AC", semester: 2, staff: SimpleStaff(name: "-"))]
//                        completionHandler(SimpleSchedule(classes: classes), nil)
                        completionHandler(nil, "Please check your information.")
                        return
                    }
                }
            }
        }
        task.resume()
    }
}
