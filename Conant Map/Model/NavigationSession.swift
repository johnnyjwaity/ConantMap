//
//  NavigationSession.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import SceneKit

class NavigationSession {
    let start:Node
    let end:Node
    let viewManager:GameViewController
    let nodes:[[Node]]
    var path:[Node]? = nil
    var displayedPath:[SCNNode] = []
    
    init(room1:String, room2:String, view:GameViewController, nodes:[[Node]]) {
        start = nodes.searchForByRoom(room1)!
        end = nodes.searchForByRoom(room2)!
        viewManager = view
        self.nodes = nodes
    }
    
    func startNav(){
        if !viewManager.visible {
            viewManager.animate()
        }
        path = Pathfinder.search(start: start, end: end, nodes: nodes[0])
        displayPath()
    }
    
    
    func displayPath(){
        removePath()
        for i in 1...(path?.count)!-1 {
            let startNode:Node = path![i]
            let endNode:Node = path![i-1]
            let n = SCNNode()
            displayedPath.append(n.buildLineInTwoPointsWithRotation(from: startNode.posiiton, to: endNode.posiiton, radius: 0.01, color: UIColor.purple))
        }
        for sn in displayedPath {
            
            viewManager.gameScene.rootNode.addChildNode(sn)
        }
    }
    
    func removePath(){
        for sn in displayedPath {
            sn.removeFromParentNode()
        }
        displayedPath = []
    }
    
    func stopNav(){
        removePath()
    }
    
}
