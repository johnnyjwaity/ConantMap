//
//  NavigationSession.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

struct NavigationSession {
    let startStr:String
    let endStr:String
    let start:Node
    let end:Node
    let usesElevators:Bool
    
    
    init(start: String, end: String, usesElevators:Bool) {
        startStr = start
        endStr = end
        var startNode:Node!
        var endNode:Node!
        for floor in Global.nodes {
            for node in floor {
                if node.rooms.contains(start) {
                    startNode = node
                }
                if node.rooms.contains(end) {
                    endNode = node
                }
            }
        }
        self.start = startNode
        self.end = endNode
        self.usesElevators = usesElevators
    }
    
}
