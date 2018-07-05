//
//  Camera.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/21/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import SceneKit
import UIKit


class Camera {
    let cam:SCNNode
    let camRig:SCNNode
    let camSpeed:Float = 0.0005
    var panVelocity:CGPoint = CGPoint(x: 0, y: 0)
    var angleSpeed:Float = 0.00005
    
    var startZoom:Float
    
    init(_ gameScene:SCNScene) {
        self.cam = gameScene.rootNode.childNode(withName: "camera", recursively: true)!
        self.camRig = gameScene.rootNode.childNode(withName: "Camera Rig", recursively: false)!
        startZoom = camRig.position.y
    }
    
    func move(_ translation:CGPoint, state:UIGestureRecognizerState, numOfTouches:Int) {
        if numOfTouches == 1 {
            switch state {
            case .changed:
                panVelocity = translation.reverse() * camSpeed
                break
            default:
                break
            }
        }
        else if numOfTouches == 2 {
            switch state {
            case .changed:
                //print(cam.eulerAngles.x)
                cam.eulerAngles.x += (-Float(translation.y) * angleSpeed)
                if cam.eulerAngles.x > 0 {
                    cam.eulerAngles.x = 0
                }
                if cam.eulerAngles.x < -1.5 {
                    cam.eulerAngles.x = -1.5
                }
                break
            default:
                break
            }
        }
        
    }
    
    func applyVelocity(){
        camRig.position = camRig.position + panVelocity
        panVelocity = panVelocity / 1.1
        
    }
    
    func zoom(_ scale:CGFloat, state:UIGestureRecognizerState){
        var moveAmount = -1 * Double(scale)
        if moveAmount < 0 {
            moveAmount /= 10
        }
        else {
            moveAmount /= 5
        }
        let forwardVector = cam.getZForward()
        switch state {
        case .changed:
            camRig.position = camRig.position + (forwardVector * moveAmount)
            break
        default:
            break
        }
    }
}
