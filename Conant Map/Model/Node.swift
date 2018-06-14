//
//  Node.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/13/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation


class Node {
    let name:String
    var x:Double = 0
    var y:Double = 0
    var connections:[Node] = []
    var strConnections:[String] = []
    var rooms:[String] = []
    
    init(_ nodeName:String) {
        name = nodeName
    }
}
