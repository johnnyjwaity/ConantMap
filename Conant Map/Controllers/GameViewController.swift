//
//  GameViewController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/4/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0
    
    var cont:OverlayController? = nil
    var overlayConstraints:[String:NSLayoutConstraint] = [:]
    let bottomConstant:CGFloat = -10
    var visible = true
    
    var navWindowCont:NavigationWindowController? = nil
    var navConstrints:[String:NSLayoutConstraint] = [:]
    let upConstant:CGFloat = UIScreen.main.bounds.height * -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        setUpView()
        //logicTest()
        spawnNodes()
    }
    
    
    
    func initView(){
        let sV = SCNView(frame: UIScreen.main.bounds)
        view.addSubview(sV)
        gameView = sV
        gameView.allowsCameraControl = true;
        gameView.autoenablesDefaultLighting = true;
    }
    
    func initScene() {
        guard let s = SCNScene(named: "art.scnassets/Map.scn")
            else{fatalError("NO Load")}
        gameScene = s
        
        gameView.scene = gameScene
        gameView.isPlaying = true;
        
        
        
    }
    func setUpView(){
//        upConstant = -1 * gameView.frame.height
        
        cont = OverlayController(parentController: self)
        let overlay = (cont?.view!)!
        
        
        gameView.addSubview(overlay)
        overlayConstraints["Bottom"] = overlay.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: bottomConstant)
        overlayConstraints["CX"] = overlay.centerXAnchor.constraint(equalTo: gameView.centerXAnchor)
        overlayConstraints["Width"] = overlay.widthAnchor.constraint(equalToConstant: gameView.frame.width * 0.65)
        overlayConstraints["Height"] = overlay.heightAnchor.constraint(equalToConstant: 100)
        for c in overlayConstraints.values {
            c.isActive = true
        }
        
        navWindowCont = NavigationWindowController()
        let win:UIView = (navWindowCont?.view)!
        win.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(win)
        navConstrints["CX"] = win.centerXAnchor.constraint(equalTo: gameView.centerXAnchor)
        navConstrints["CY"] = win.centerYAnchor.constraint(equalTo:gameView.centerYAnchor, constant: upConstant)
        navConstrints["Width"] = win.widthAnchor.constraint(equalToConstant: gameView.frame.width * 0.66)
        navConstrints["Height"] = win.heightAnchor.constraint(equalToConstant: gameView.frame.width * 0.66)
        for c in navConstrints.values {
            c.isActive = true
        }
        
        
        let swipeListener = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeListener.direction = .up
        overlay.addGestureRecognizer(swipeListener)
        
        let swipeListenerDown = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeListenerDown.direction = .down
        overlay.addGestureRecognizer(swipeListenerDown)
    }
    
    
    @objc
    func swiped(gesture:UIGestureRecognizer){
        if let sG = gesture as? UISwipeGestureRecognizer {
            if sG.direction == UISwipeGestureRecognizerDirection.down && visible {
                animate()
            }
            else if sG.direction == UISwipeGestureRecognizerDirection.up && !visible {
                animate()
            }
        }
    }
    
    func animate(){
        visible = !visible
        
        if visible {
            overlayConstraints["Bottom"]?.constant = -10
            navConstrints["CY"]?.constant = upConstant
        }
        else {
            overlayConstraints["Bottom"]?.constant = (cont?.view.frame.height)!
            navConstrints["CY"]?.constant = 0
        }
        
        
        
        UIView.animate(withDuration: 0.5) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    func createTarget(){
        let geometry:SCNGeometry = SCNPyramid(width: 1, height: 1, length:1)
        geometry.materials.first?.diffuse.contents = UIColor.red
        let geoNode = SCNNode(geometry: geometry)
        gameScene.rootNode.addChildNode(geoNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            
        }
    }
    
    func spawnNodes(){
        let nodes = NodeParser.parse(file: "floor1")
        for n in nodes {
            let g = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
            g.firstMaterial?.diffuse.contents = UIColor.purple
            let sn = SCNNode(geometry: g)
            sn.position = SCNVector3(n.x * -1, -0.389, n.y)
            n.posiiton = sn.position
            gameScene.rootNode.addChildNode(sn)
        }
        
        let nodes2:[Node] = NodeParser.parse(file: "floor2")
        let y = 0.804
        for n in nodes2 {
            let g = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
            g.firstMaterial?.diffuse.contents = UIColor.purple
            let sn = SCNNode(geometry: g)
            sn.position = SCNVector3((n.x * -1) + 2.2840004, y, n.y - 0.522)
            n.posiiton = sn.position
            gameScene.rootNode.addChildNode(sn)
        }
        //print(NodeParser.searchForNode(name: "Node", nodes: nodes2)?.posiiton)
    }
    
    
    
    
    
    
    
    
    
    
    

}
