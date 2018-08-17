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

class MapViewController: UIViewController, SCNSceneRendererDelegate, OverlayDelegate, FloorSelectDelegate {
    
    
    static var main:MapViewController? = nil
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    
    var overlayController:OverlayController? = nil
    var bottomAnchor:NSLayoutConstraint? = nil
    var bottomConstant:CGFloat = -20
    
    var nodes:[[Node]] = []
    var rooms:[String] = []
    
    var camera:Camera? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapViewController.main = self
        initView()
        initScene()
        initNodes()
        initRooms()
        setUpView()
        
    }
    
    
    
    func initView(){
        let sV = SCNView(frame: UIScreen.main.bounds)
        view.addSubview(sV)
        gameView = sV
        gameView.autoenablesDefaultLighting = true;
        gameView.delegate = self
    }
    
    func initScene() {
        guard let s = SCNScene(named: "art.scnassets/Map.scn")
            else{fatalError("NO Load")}
        gameScene = s
        
        gameView.scene = gameScene
        gameView.isPlaying = true;
        camera = Camera(gameScene)
    }
    
    func setUpView(){
        overlayController = OverlayController()
        overlayController?.delegate = self
        let overlay:UIView = (overlayController?.view)!
        gameView.addSubview(overlay)
        overlay.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 20).isActive = true
        overlay.topAnchor.constraint(equalTo: gameView.topAnchor, constant: 20).isActive = true
        bottomAnchor = overlay.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: bottomConstant)
        bottomAnchor?.isActive = true
        overlay.widthAnchor.constraint(equalToConstant: 300).isActive = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        overlayController?.dragBar.addGestureRecognizer(pan)
        
        let floorSelect = FloorSelectController()
        floorSelect.delegate = self
        addChildViewController(floorSelect)
        gameView.addSubview(floorSelect.view)
        floorSelect.view.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -20).isActive = true
        floorSelect.view.topAnchor.constraint(equalTo: gameView.topAnchor, constant: 20).isActive = true
        floorSelect.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floorSelect.view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        let gamePan = UIPanGestureRecognizer(target: self, action: #selector(handleCameraMove(gesture:)))
        gameView.addGestureRecognizer(gamePan)
        
        let zoom = UIPinchGestureRecognizer(target: self, action: #selector(handleCameraZoom(gesture:)))
        gameView.addGestureRecognizer(zoom)
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleCameraRotate(gesture:)))
        gameView.addGestureRecognizer(rotate)
    }
    
    @objc
    func handleCameraMove(gesture:UIPanGestureRecognizer){
        camera?.move(gesture.velocity(in: gameView), state: gesture.state, numOfTouches: gesture.numberOfTouches)
    }
    @objc
    func handleCameraZoom(gesture:UIPinchGestureRecognizer) {
        camera?.zoom(gesture.velocity, state: gesture.state)
    }
    var schoolRotation:Float!
    @objc
    func handleCameraRotate(gesture:UIRotationGestureRecognizer) {
        let school = gameScene.rootNode.childNode(withName: "School", recursively: false)!
        switch gesture.state {
        case .began:
            schoolRotation = school.eulerAngles.y
            break
        case .changed:
            school.eulerAngles.y = schoolRotation + Float(-gesture.rotation)
            break
        case .ended:
            schoolRotation = school.eulerAngles.y
            break
        default:
            break
        }
    }
    
    @objc
    func handlePan(gesture:UIGestureRecognizer){
        let panGesture:UIPanGestureRecognizer = gesture as! UIPanGestureRecognizer
        let translation = panGesture.translation(in: gameView)
        switch panGesture.state {
        case .began:
            break
        case .changed:
            bottomAnchor?.constant = bottomConstant + translation.y
            break
        case .ended:
            bottomConstant = (bottomAnchor?.constant)!
            break
        default:
            break
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        camera?.applyVelocity()
    }
    
    /*Loads Nodes into The application */
    func initNodes(){
        //Prepares Arrays For Nodes
        var floor1Nodes:[Node] = []
        var floor2Nodes:[Node] = []
        //Recieves all Nodes from File
        let allNodes = NodeParser.parse(file: "nodes")
        //Gets Node for the school
        let schoolNode:SCNNode = gameScene.rootNode.childNode(withName: "School", recursively: false)!
        //Iterates over each node to determine which floor it is on
        for n in allNodes {
            if let sn1:SCNNode = schoolNode.childNode(withName: "Floor1", recursively: false)?.childNode(withName: "Nodes1", recursively: false)?.childNode(withName: n.name, recursively: false){
                let min = sn1.geometry?.boundingBox.min
                let max = sn1.geometry?.boundingBox.max
                let mid = min?.midpoint(max!)
                let marker = SCNNode()
                sn1.addChildNode(marker)
                marker.position = mid!
                n.position = marker.worldPosition
                
                //print(sn1.position)
                n.floor = 1
                n.sceneNode = sn1
                //Changes Node color to clear
                sn1.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                floor1Nodes.append(n)
            }
            else if let sn2:SCNNode = schoolNode.childNode(withName: "Floor2", recursively: false)?.childNode(withName: "Nodes2", recursively: false)?.childNode(withName: n.name, recursively: false){
                let min = sn2.geometry?.boundingBox.min
                let max = sn2.geometry?.boundingBox.max
                let mid = min?.midpoint(max!)
                let marker = SCNNode()
                sn2.addChildNode(marker)
                marker.position = mid!
                n.position = marker.worldPosition
                n.floor = 2
                n.sceneNode = sn2
                //Changes Node Color To Clear
                sn2.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                floor2Nodes.append(n)
            }else{
                print("No Scene Node Found")
            }
        }
        //Sets Nodes variable with both arrays
        nodes = [floor1Nodes, floor2Nodes]
        Global.nodes = nodes
    }
    
    /*Gets All Rooms from nodes */
    func initRooms(){
        rooms = []
        for floorArray:[Node] in nodes {
            for node:Node in floorArray {
                for room in node.rooms {
                    rooms.append(room)
                }
            }
        }
        Global.rooms = rooms
    }
    
    func resizeOverlay(_ size: OverlaySize) {
        var newBottomConstant = bottomConstant
        switch size {
        case .Large:
            newBottomConstant = -20
            break
        case .Medium:
            newBottomConstant = -496.5
        case .Small:
            newBottomConstant = -688
            break
        }
        bottomConstant = newBottomConstant
        bottomAnchor?.constant = newBottomConstant
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func changeFloor(_ floor: Int) {
        let floor1Node = gameScene.rootNode.childNode(withName: "Floor1", recursively: true)!
        let floor2Node = gameScene.rootNode.childNode(withName: "Floor2", recursively: true)!
        
        switch floor {
        case 1:
            floor1Node.isHidden = false
            floor2Node.isHidden = true
            break
        case 2:
            floor1Node.isHidden = true
            floor2Node.isHidden = false
        default:
            break
        }
        
    }
    
    func startNavigation(_ session: NavigationSession) {
        guard let path = Pathfinder.search(start: session.start, end: session.end) else{
            return
        }
        drawPath(path, radius: 0.1, color: UIView().tintColor)
    }
    
    func drawPath(_ path:[Node], radius:CGFloat, color:UIColor){
        var prev:Node? = nil
        for n in path {
            if prev == nil {
                prev = n
                continue
            }
            print("Creating Line")
            print(n.position)
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = n.position
            gameScene.rootNode.addChildNode(sphereNode)
            gameScene.rootNode.addChildNode(SCNNode().buildLineInTwoPointsWithRotation(from: (prev?.position)!, to: n.position, radius: radius, color: color))
            prev = n
        }
    }
    

}
class   CylinderLine: SCNNode
{
    init( parent: SCNNode,//Needed to add destination point of your line
        v1: SCNVector3,//source
        v2: SCNVector3,//destination
        radius: CGFloat,//somes option for the cylinder
        radSegmentCount: Int, //other option
        color: UIColor )// color of your node object
    {
        super.init()
        print(v1)
        print(v2)
        //Calcul the height of our line
        let  height = v1.distance(receiver: v2)
        print(height)
        
        //set position to v1 coordonate
        position = v1
        
        //Create the second node to draw direction vector
        let nodeV2 = SCNNode()
        
        //define his position
        nodeV2.position = v2
        //add it to parent
        parent.addChildNode(nodeV2)
        
        //Align Z axis
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(M_PI_2)
        
        //create our cylinder
        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        cyl.radialSegmentCount = radSegmentCount
        cyl.firstMaterial?.diffuse.contents = color
        
        //Create node with cylinder
        let nodeCyl = SCNNode(geometry: cyl )
        nodeCyl.position.y = -height/2
        zAlign.addChildNode(nodeCyl)
        
        //Add it to child
        addChildNode(zAlign)
        
        //set contrainte direction to our vector
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private extension SCNVector3{
    func distance(receiver:SCNVector3) -> Float{
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
}
