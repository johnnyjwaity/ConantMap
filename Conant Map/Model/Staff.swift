//
//  Staff.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

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
}
