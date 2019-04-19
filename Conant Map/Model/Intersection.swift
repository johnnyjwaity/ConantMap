//
//  Intersection.swift
//  Conant Map
//
//  Created by Johnny Waity on 4/11/19.
//  Copyright © 2019 Johnny Waity. All rights reserved.
//

import Foundation


struct Intersection:Codable{
    let node:String
    let paths:[IntersectionPath]
}
struct IntersectionPath:Codable {
    let start:String
    let end:String
    let message:String
}
