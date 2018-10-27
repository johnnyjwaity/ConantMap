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
    
    var startRotation:Float
    let gameScene:SCNScene!
    
    
    init(_ gameScene:SCNScene) {
        self.cam = gameScene.rootNode.childNode(withName: "camera", recursively: true)!
        self.camRig = gameScene.rootNode.childNode(withName: "Camera Rig", recursively: false)!
        startRotation = camRig.eulerAngles.y
        self.gameScene = gameScene
    }
    
    func move(_ translation:CGPoint, state:UIGestureRecognizer.State, numOfTouches:Int) {
        if numOfTouches == 1 {
            switch state {
            case .changed:
                let zoomLevel = abs(camRig.position.y) / 12.64
                panVelocity = translation.reverse() * camSpeed * zoomLevel
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
    
    func panToPosition(_ positionR:SCNVector3, type:PanType, room:Structure?, floor:Int){
        var position = positionR
//        print(positionR)
        if type == .Room{
            let testNode = SCNNode()
            if room == nil {
                gameScene.rootNode.childNode(withName: "School", recursively: false)?.addChildNode(testNode)
            }
            else{
                room?.node.addChildNode(testNode)
            }
            
            testNode.position = positionR
            position = testNode.worldPosition
        }
        else{
            position = positionR
        }
        
        position.y += (floor == 1) ? 4.5 : 5
        position.x -= (floor == 1) ? 1 : 0
        position.z += (floor == 1) ? 6 : 6
//        print(positionR)
        
        let panAnimation = CABasicAnimation(keyPath: "position")
        panAnimation.fromValue = NSValue(scnVector3: camRig.position)
        panAnimation.toValue = NSValue(scnVector3: position)
        panAnimation.duration = 0.4
        self.camRig.position = position
        camRig.addAnimation(panAnimation, forKey: nil)
        
        
        let tiltAnimation = CABasicAnimation(keyPath: "eulerAngles.x")
        tiltAnimation.fromValue = cam.eulerAngles.x
        tiltAnimation.toValue = -0.452859402
        tiltAnimation.duration = 0.4
        cam.eulerAngles.x = -0.452859402
        cam.addAnimation(tiltAnimation, forKey: nil)
    }
    
    func showWholeMap(){
        let center = SCNVector3(x: 2.392, y: 25, z: 19.874)
        let panAnimation = CABasicAnimation(keyPath: "position")
        panAnimation.fromValue = NSValue(scnVector3: camRig.position)
        panAnimation.toValue = NSValue(scnVector3: center)
        panAnimation.duration = 0.4
        self.camRig.position = center
        camRig.addAnimation(panAnimation, forKey: nil)
        
        
        let tiltAnimation = CABasicAnimation(keyPath: "eulerAngles.x")
        tiltAnimation.fromValue = cam.eulerAngles.x
        tiltAnimation.toValue = -1.5
        tiltAnimation.duration = 0.4
        cam.eulerAngles.x = -1.5
        cam.addAnimation(tiltAnimation, forKey: nil)
    }
    
    func applyVelocity(){
        camRig.position = camRig.position + panVelocity
        panVelocity = panVelocity / 1.1
        
    }
    
    func zoom(_ scale:CGFloat, state:UIGestureRecognizer.State){
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
            let translation = forwardVector * moveAmount
//            let prevPosition = SCNVector3(camRig.position.x, camRig.position.y, camRig.position.z);
//            print("Translation: \(translation)")
            camRig.position = camRig.position + translation
//            if translation.x != Float.nan && translation.y != Float.nan && translation.z != Float.nan {
//
//            }
//            print(camRig.position)
            
            
            break
        default:
            break
        }
    }
    
    func rotate(_ rotation:Float, state:UIGestureRecognizer.State){
        switch state {
        case .began:
            startRotation = camRig.eulerAngles.y
            break
        case .changed:
            camRig.eulerAngles.y = startRotation + rotation
            break
        case .ended:
            startRotation = camRig.eulerAngles.y
            break
        default:
            break
        }
    }
}

enum PanType{
    case Node
    case Room
}
