//
//  Class.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

class Class {
    
    
    
    var name:String!
    var period:String!
    var location:String!
    var id:String!
    var staff:Staff!
    var semester:Int!
    init(_ name:String) {
        self.name = name
    }
    init(period:String) {
        self.period = period
    }
}
