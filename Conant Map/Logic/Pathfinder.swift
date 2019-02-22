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
    
    static func search(start:Node, end:Node, useElevator:Bool) -> [[Node]]? {
        for room in end.rooms {
            if start.rooms.contains(room){
                return [[start]]
            }
        }
        if start.floor != end.floor{
            var closestStair:Stair? = nil
            var closestDistance:Float = -1
            for stair in Global.stairs{
                if stair.floor != start.floor {
                    continue
                }
                if stair.isElevator != useElevator {
                    continue
                }
                let distance = calculateHeuristic(.ManhattenDistance, currentNode: start, endNode: stair.entryNode!)
                if closestStair == nil {
                    closestStair = stair
                    closestDistance = distance
                    continue
                }
                
                if distance < closestDistance {
                    closestDistance = distance
                    closestStair = stair
                }
            }
            let points:[Node] = [start, (closestStair?.entryNode)!, (closestStair?.complementary.entryNode)!, end]
            return performMultiPath(points)
        }
        else{
            return [findPath(start: start, end: end)!]
        }
    }
    
    static func performMultiPath(_ path:[Node]) -> [[Node]]?{
        return [findPath(start: path[0], end: path[1])!, findPath(start: path[2], end: path[3])!]
    }
    
    static func findPath(start:Node, end:Node) -> [Node]? {
        
        
        
        let nodes = Global.nodes[start.floor-1]
        
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
    static func getDirections(_ paths:[[Node]]){
        for path in paths {
            var counter = 0
            for node in path {
                if counter + 2 < path.count {
                    let a = node.position.distance(receiver: path[counter + 1].position)
                    let b = path[counter + 2].position.distance(receiver: path[counter + 1].position)
                    let c = node.position.distance(receiver: path[counter + 2].position)
                    
                    let angle = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b))
                    if angle > Float.pi / 4 && angle < (Float.pi / 4) * 3 {
                        let aPos = node.position
                        let bPos = path[counter + 1].position
                        let cPos = path[counter + 2].position
                        let isRight = isPointRightOfRay(xParam: cPos.x, yParam: cPos.z, raySxParam: aPos.x, raySyParam: aPos.z, rayExParam: bPos.x, rayEyParam: bPos.z)
                        print("Turn \(isRight ? "Right" : "Left")")
                    }
                }
                counter += 1
            }
        }
    }
    
    static func isPointRightOfRay(xParam:Float, yParam:Float, raySxParam:Float, raySyParam:Float, rayExParam:Float, rayEyParam:Float) -> Bool{
        var theCos:Float = 0
        var theSin:Float = 0
        var dist:Float = 0
        
        var rayEx = rayExParam
        var rayEy = rayEyParam
        let raySx = raySxParam
        let raySy = raySyParam
        var x = xParam
        var y = yParam
    //  Translate the system so that the ray
    //  starts on the origin.
        rayEx -= raySx;
        rayEy -= raySy;
        x -= raySx;
        y -= raySy;
    
    //  Discover the ray’s length.
        dist=sqrt(rayEx * rayEx + rayEy * rayEy);
    
    //  Rotate the system so that the ray
    //  points along the positive X-axis.
        theCos = rayEx / dist;
        theSin = rayEy / dist;
        y = y * theCos - x * theSin;
    
    //  Return the result.
        return y > 0;
        
    }
    
}

enum Heuristic {
    case ManhattenDistance
}
