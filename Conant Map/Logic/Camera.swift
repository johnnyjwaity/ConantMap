//
//  Camera.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/21/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import SceneKit


class Camera {
    let cam:SCNNode
    let camRig:SCNNode
    let camSpeed:Float = 0.05
    
    var currentTouchAmount = 0
    
    
    init(_ gameScene:SCNScene) {
        self.cam = gameScene.rootNode.childNode(withName: "camera", recursively: true)!
        self.camRig = gameScene.rootNode.childNode(withName: "Camera Rig", recursively: false)!
    }
    
    
    func handleInput(_ gesture:UIGestureRecognizer){
        let pg = gesture as! UIPanGestureRecognizer
        moveCamera(pg)
    }
    
    func moveCamera(_ gesture:UIPanGestureRecognizer){
        switch gesture.numberOfTouches {
        case 1:
            handleMove(gesture)
            break
        case 2:
            handlePan(gesture)
            break
        default:
            break
        }
    }
    
    func handlePan(_ gesture:UIPanGestureRecognizer){
        
    }
    
    func handleMove(_ gesture:UIPanGestureRecognizer){
        var velocity = gesture.velocity(in: nil).toVector()
        velocity = velocity.multiply(camSpeed)
        camRig.position.z += velocity.z
        camRig.position.x += velocity.x
        
        
    }
    
}
