//
//  Pathfinder.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/16/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import SceneKit
import UIKit


class Pathfinder {
    static func search(start:Node, end:Node, nodes:[Node]) -> [Node]? {
        
        var parents:[Node:Node?] = [:]
        for n in nodes {
            parents[n] = nil
        }
        var heuristics:[Node:Float] = [:]
        for n in nodes {
            heuristics[n] = calculateHeuristic(.ManhattenDistance, currentNode: n, endNode: end)
        }
        
        
        var openList:[Node] = []
        var closedList:[Node] = []
        closedList.append(start)
        while true {
            for cn in closedList {
                for con in cn.connections {
                    if !closedList.contains(con) {
                        if !openList.contains(con){
                            openList.append(con)
                            parents[con] = cn
                        }
                        else {
                            if let curParent = parents[con]! {
                                let currentDisance = distance(pos1: con.position, pos2: curParent.position)
                                let newDistane = distance(pos1: con.position, pos2: cn.position)
                                if newDistane < currentDisance {
                                    parents[con] = cn
                                }
                            }
                            else{
                                parents[con] = cn
                            }
                        }
                    }
                }
            }
            var smallestFnum:Float = -1
            var smallestFnode:Node? = nil
            for oNode in openList {
                if oNode.name == end.name {
                    //Found End
                    var path:[Node] = []
                    var currentNode = oNode
                    while true {
                        path.append(currentNode)
                        //let poNode = parents[currentNode]
                        if let poNode = parents[currentNode] {
                            if let pNode = poNode {
                                currentNode = pNode
                            }
                            else {
                                break
                            }
                        }
                        else {
                            break
                        }
                    }
                    return path.reversed()
                }
                let oParent:Node = parents[oNode]!!
                let f = heuristics[oNode]! + distance(pos1: oNode.position, pos2: oParent.position)
                if smallestFnode == nil || f < smallestFnum {
                    smallestFnum = f
                    smallestFnode = oNode
                }
            }
            openList.remove(at: indexOfNode(node: smallestFnode!, array: openList))
            closedList.append(smallestFnode!)
        }
        //return nil
    }
    static func calculateHeuristic(_ heuristic:Heuristic, currentNode:Node, endNode:Node) -> Float {
        switch heuristic {
        case .ManhattenDistance:
            return abs(currentNode.position.x - endNode.position.x) + abs(currentNode.position.z - endNode.position.z)
        }
    }
    static func distance(pos1:SCNVector3, pos2:SCNVector3) -> Float {
        let xset = powf(pos2.x - pos1.x, 2)
        let yset = powf(pos2.y - pos1.y, 2)
        let zset = powf(pos2.z - pos1.z, 2)
        return sqrt(xset + yset + zset)
    }
    static func indexOfNode (node:Node, array:[Node]) -> Int {
        var counter = 0
        for n in array {
            if n.name == node.name {
                return counter
            }
            counter += 1
        }
        return -1
    }
    
}

enum Heuristic {
    case ManhattenDistance
}
