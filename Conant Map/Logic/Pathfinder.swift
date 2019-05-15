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
            var path = performMultiPath(points)
            var firstPath = path?.first
            let stairNode = Node("Start Stair", id: 5002)
            stairNode.floor = (firstPath?.first?.floor)!
            stairNode.position = (closestStair?.postion)!
            firstPath?.append(stairNode)
            
            var secondPath = path?.last
            let stairNode2 = Node("End Stair", id: 5003)
            stairNode2.floor = (secondPath?.first?.floor)!
            stairNode2.position = (closestStair?.complementary.postion)!
            secondPath?.insert(stairNode2, at: 0)
            path = [firstPath!, secondPath!]
            return path
        }
        else{
            return [findPath(start: start, end: end)!]
        }
    }
    
    static func performMultiPath(_ path:[Node]) -> [[Node]]?{
        return [findPath(start: path[0], end: path[1])!, findPath(start: path[2], end: path[3])!]
    }
    
    static func findPath(start:Node, end:Node) -> [Node]? {
        
        if start == end {
            return [start]
        }
        
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
    static func getDirections(_ paths:[[Node]]) -> [Node:WalkDirection]{
        var directions:[Node:WalkDirection] = [:]
        var pathCount = 1
        for path in paths {
            if path.count - 2 < 1 {
                continue
            }
            for i in 1...path.count-2 {
                let d1 = path[i].position.distance(receiver: path[i-1].position)
                let d2 = path[i].position.distance(receiver: path[i+1].position)
                let d3 = path[i-1].position.distance(receiver: path[i+1].position)
                var angle = acos((pow(d1, 2) + pow(d2, 2) - pow(d3, 2)) / (2 * d1 * d2))
                angle = angle * (180 / Float.pi)
                if angle > 70 && angle < 110 {
                    let isLeft = isPointLeftOfRay(xParam: path[i + 1].position.x, yParam: path[i + 1].position.z, raySxParam: path[i].position.x, raySyParam: path[i].position.z, rayExParam: path[i - 1].position.x, rayEyParam: path[i-1].position.z)
                    if i == path.count - 2 {
                        if pathCount == 1 && paths.count > 1 {
                            directions[path[i]] = isLeft ? WalkDirection.stairLeft : WalkDirection.stairRight
                        }else{
                            directions[path[i]] = isLeft ? WalkDirection.destinationLeft : WalkDirection.destinationRight
                        }
                    }else{
                        directions[path[i]] = isLeft ? WalkDirection.left : WalkDirection.right
                    }
                    
                }
            }
            
            if pathCount == 1 && paths.count > 1 {
                directions[path[path.count - 1]] = path[0].floor == 1 ? WalkDirection.up : WalkDirection.down
            }else{
                directions[path[path.count - 1]] = WalkDirection.arrive
            }
            pathCount += 1
        }
        return directions
    }
//    var counter = 0
//    for node in path {
//    if counter + 2 < path.count {
//    let a = node.position.distance(receiver: path[counter + 1].position)
//    let b = path[counter + 2].position.distance(receiver: path[counter + 1].position)
//    let c = node.position.distance(receiver: path[counter + 2].position)
//
//    let angle = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b))
//    if angle > 70 * (Float.pi / 180) && angle < 110 * (Float.pi / 180) {
//    let aPos = node.position
//    let bPos = path[counter + 1].position
//    let cPos = path[counter + 2].position
//    let isRight = isPointRightOfRay(xParam: cPos.x, yParam: cPos.z, raySxParam: aPos.x, raySyParam: aPos.z, rayExParam: bPos.x, rayEyParam: bPos.z)
//    directions[node] = isRight ? WalkDirection.right : WalkDirection.left
//    }
//    }
//
//    if pathCount == 1 && paths.count > 1 {
//    if counter + 1 == path.count {
//    if paths[1][0].floor == 2 {
//    directions[node] = WalkDirection.up
//    }else{
//    directions[node] = WalkDirection.down
//    }
//    }
//    }
//
//    counter += 1
//    }
    
    static func simplifyPath(_ ogPathParam:[[Node]]?) -> [[Node]]? {
        if ogPathParam == nil {
            return nil
        }
        var ogPath = ogPathParam!
        for p in ogPath {
            if p.count - 2 < 1 {
                continue
            }
            var path = p
            var indeciesToRemove:[Int] = []
            for i in 1...path.count-2 {
                let d1 = path[i].position.distance(receiver: path[i-1].position)
                let d2 = path[i].position.distance(receiver: path[i+1].position)
                let d3 = path[i-1].position.distance(receiver: path[i+1].position)
                var angle = acos((pow(d1, 2) + pow(d2, 2) - pow(d3, 2)) / (2 * d1 * d2))
                angle = angle * (180 / Float.pi)
//                print(angle)
                if angle > 175 || angle.isNaN {
                    indeciesToRemove.insert(i, at: 0)
                }
            }
            for remove in indeciesToRemove {
                path.remove(at: remove)
            }
            ogPath[ogPath.firstIndex(of: p)!] = path
        }
        return ogPath
    }
    
    static func isPointLeftOfRay(xParam:Float, yParam:Float, raySxParam:Float, raySyParam:Float, rayExParam:Float, rayEyParam:Float) -> Bool{
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
enum WalkDirection {
    case left
    case right
    case up
    case down
    case stairRight
    case stairLeft
    case destinationRight
    case destinationLeft
    case arrive
    case forward
    case backward
}
