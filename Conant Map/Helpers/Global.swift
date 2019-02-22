//
//  Global.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/28/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
struct Global {
    static var rooms:[String] = []
    static var nodes:[[Node]] = []
    static var stairs:[Stair] = []
    static var structures:[Structure] = []
    static var staff:[Staff] = []
    static var classes:[Class] = []
    static var macAddresses:[MacAddress] = []
    static let departments:[String:String] = ["Student Services": "Student Services Desk",
                                              "Math": "Math Office",
                                              "Physical Education": "Gym",
                                              "World Language": "World Language Office",
                                              "Social Studies": "213",
                                              "English": "English Office",
                                              "Family and Consumer Sciences": "173",
                                              "Business Education": "Business Office",
                                              "Art": "Art Office",
                                              "English As A Second Language": "English Office",
                                              "Science": "Science Office",
                                              "Special Education": "Special Ed Office",
                                              "English as a Second Language": "English Office",
                                              "Music": "Music Office",
                                              "Applied Technology": "Applied Tech Office",
                                              "Driver Education": "114",
                                              "Health": "Gym"]
}
