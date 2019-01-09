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
import CoreLocation

class MapViewController: UIViewController, SCNSceneRendererDelegate, OverlayDelegate, FloorSelectDelegate, RouteBarDelegate, OptionsDelegate, CLLocationManagerDelegate {
    
    
    
    static var main:MapViewController? = nil
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    
    var overlayController:OverlayController? = nil
    var bottomAnchor:NSLayoutConstraint? = nil
    var leftAnchor:NSLayoutConstraint!
    var bottomConstant:CGFloat = -20
    
    var routeBar:RouteController!
    var routeBottomAnchor:NSLayoutConstraint!
    
    var floorSelect:FloorSelectController!
    
//    var nodes:[[Node]] = []
//    var rooms:[String] = []
    
    var camera:Camera? = nil
    
    var currentNavSession:NavigationSession? = nil
    
    var highlightedRooms:[Structure] = []
    var roomLabels:[[SCNNode]]!
    
    let locationManager = CLLocationManager()
    
    var gpsPoints:[SCNNode] = []
    let gpsCoordinates = [[42.035705, -88.064329], [42.036693, -88.061544], [42.037123, -88.062951]]
    var scale:[Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapViewController.main = self
        initView()
        initScene()
        initNodes()
        initRooms()
        initStructures()
        initStairs()
        initStaff()
        setUpView()
        
        displayLabels()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabelDisplay), name: Notification.Name("ChangeRoomLabelDispaly"), object: nil)
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if gpsPoints.count == 0{
            if let gp1 = gameScene.rootNode.childNode(withName: "GPS_1", recursively: false){
                if let gp2 = gameScene.rootNode.childNode(withName: "GPS_2", recursively: false) {
                    if let gp3 = gameScene.rootNode.childNode(withName: "GPS_3", recursively: false){
                        gpsPoints.append(gp1)
                        gpsPoints.append(gp2)
                        gpsPoints.append(gp3)
                    }
                }
            }
        }else{
            let currentLat = (locations.last?.coordinate.latitude)!
            let currentLong = (locations.last?.coordinate.longitude)!
            
            let coordDistance = haversine(x1: gpsCoordinates[0][0], y1: gpsCoordinates[0][1], x2: gpsCoordinates[1][0], y2: gpsCoordinates[1][1])
            let pixelDisatnce = distance(x1: Double(gpsPoints[0].position.x), y1: Double(gpsPoints[0].position.z), x2: Double(gpsPoints[1].position.x), y2: Double(gpsPoints[1].position.z))
            
            let pixelsToCoords = pixelDisatnce / coordDistance
            print(pixelsToCoords)
            
            let d1c = haversine(x1: currentLat, y1: currentLong, x2: gpsCoordinates[0][0], y2: gpsCoordinates[0][1])
            let d2c = haversine(x1: currentLat, y1: currentLong, x2: gpsCoordinates[1][0], y2: gpsCoordinates[1][1])
            let d3c = haversine(x1: currentLat, y1: currentLong, x2: gpsCoordinates[2][0], y2: gpsCoordinates[2][1])
            print("\(d1c / 1000) \(d2c / 1000) \(d3c / 1000)")
            
            let d1p = d1c * pixelsToCoords
            let d2p = d2c * pixelsToCoords
            let d3p = d3c * pixelsToCoords

            print("\(d1p) \(d2p) \(d3p)")
//
            let points = circleIntersection(x1: Double(gpsPoints[0].position.x), y1: Double(gpsPoints[0].position.z), r1: d1p, x2: Double(gpsPoints[1].position.x), y2: Double(gpsPoints[1].position.z), r2: d2p)
            print(points)
            
//            let node1 = SCNNode(geometry: SCNSphere(radius: 1))
//            node1.position = SCNVector3(points[0], 0, points[1])
//            node1.geometry?.materials.first?.diffuse.contents = UIColor.blue
//
//            let node2 = SCNNode(geometry: SCNSphere(radius: 1))
//            node2.position = SCNVector3(points[2], 0, points[3])
//            node2.geometry?.materials.first?.diffuse.contents = UIColor.orange
//
//            gameScene.rootNode.addChildNode(node1)
//            gameScene.rootNode.addChildNode(node2)
            let p1d = distance(x1: points[0], y1: points[1], x2: Double(gpsPoints[2].position.x), y2: Double(gpsPoints[2].position.z))
            let p2d = distance(x1: points[2], y1: points[3], x2: Double(gpsPoints[2].position.x), y2: Double(gpsPoints[2].position.z))
            
            let difference1 = abs(p1d - d3p)
            let difference2 = abs(p2d - d3p)
//
            var x:Float
            var y:Float
            if difference1 <= difference2 {
                x = Float(points[0])
                y = Float(points[1])
            }else{
                x = Float(points[2])
                y = Float(points[3])
            }
            gameScene.rootNode.childNode(withName: "location", recursively: false)?.position.x = x
            gameScene.rootNode.childNode(withName: "location", recursively: false)?.position.z = y
        }
        
//        print("\(locations.last?.coordinate.latitude) \(locations.last?.coordinate.longitude)")
        
    }
    func distance(x1:Double, y1:Double, x2:Double, y2:Double) -> Double{
        return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
    }
    func haversine(x1:Double, y1:Double, x2:Double, y2:Double) -> Double{
        let r = 6371e3
        let a1 = x1 * (Double.pi / 180)
        let a2 = x2 * (Double.pi / 180)
        
        let latDif = (x2 - x1) * (Double.pi / 180)
        let longDif = (y2 - y1) * (Double.pi / 180)
        
        let a = sin(latDif / 2) * sin(latDif / 2) + cos(a1) * cos(a2) * sin(longDif / 2) * sin(longDif / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return r * c
    }
    
    func circleIntersection(x1:Double, y1:Double, r1:Double, x2:Double, y2:Double, r2:Double) -> [Double]{
        let dx = x2 - x1
        let dy = y2 - y1
        
        let d = sqrt(dy * dy + dx * dx)
        
        if d > r1 + r2 {
            return []
        }
        if d < abs(r1 - r2) {
            return []
        }
        
        let a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
        
        let x = x1 + (dx * a) / d
        let y = y1 + (dy * a) / d
        
        let h = sqrt(r1 * r1 - a * a)
        
        let rx = -dy * (h / d)
        let ry = dx * (h / d)
        
        let xi = x + rx
        let yi = y + ry
        
        let xi2 = x - rx
        let yi2 = y - ry
        
        return [xi, yi, xi2, yi2]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
//        gameView.allowsCameraControl = true
        camera = Camera(gameScene)
        
        
    }
    
    func setUpView(){
        overlayController = OverlayController()
        overlayController?.delegate = self
        let overlay:UIView = (overlayController?.view)!
        gameView.addSubview(overlay)
        leftAnchor = overlay.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 20)
        leftAnchor.isActive = true
        overlay.topAnchor.constraint(equalTo: gameView.topAnchor, constant: 20).isActive = true
        bottomAnchor = overlay.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: bottomConstant)
        bottomAnchor?.isActive = true
        overlay.widthAnchor.constraint(equalToConstant: 300).isActive = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        overlayController?.dragBar.addGestureRecognizer(pan)
        
        routeBar = RouteController()
        routeBar.delegate = self
        self.addChild(routeBar)
        gameView.addSubview(routeBar.view)
        routeBottomAnchor = routeBar.view.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: 100)
        routeBottomAnchor.isActive = true
        routeBar.view.widthAnchor.constraint(equalTo: gameView.widthAnchor, multiplier: 0.6).isActive = true
        routeBar.view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        routeBar.view.centerXAnchor.constraint(equalTo: gameView.centerXAnchor).isActive = true
        routeBar.setupView(NavigationSession(start: "180", end: "280", usesElevators: false))
        
        floorSelect = FloorSelectController()
        floorSelect.delegate = self
        addChild(floorSelect)
        gameView.addSubview(floorSelect.view)
        floorSelect.view.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -20).isActive = true
        floorSelect.view.topAnchor.constraint(equalTo: gameView.topAnchor, constant: 20).isActive = true
        floorSelect.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floorSelect.view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let optionController = OptionsController()
        optionController.delegate = self
        optionController.view.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(optionController.view)
        addChild(optionController)
        optionController.view.topAnchor.constraint(equalTo: floorSelect.view.bottomAnchor, constant: 20).isActive = true
        optionController.view.centerXAnchor.constraint(equalTo: floorSelect.view.centerXAnchor).isActive = true
        optionController.view.widthAnchor.constraint(equalTo: floorSelect.view.widthAnchor).isActive = true
        optionController.view.heightAnchor.constraint(equalToConstant: 132.5).isActive = true
        
        
        let gamePan = UIPanGestureRecognizer(target: self, action: #selector(handleCameraMove(gesture:)))
        gameView.addGestureRecognizer(gamePan)

        let zoom = UIPinchGestureRecognizer(target: self, action: #selector(handleCameraZoom(gesture:)))
        gameView.addGestureRecognizer(zoom)

//        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleCameraRotate(gesture:)))
//        gameView.addGestureRecognizer(rotate)
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
        var file = "fallback"
        if let f = UserDefaults.standard.object(forKey: "nodes") as? String {
            file = f
        }
        let allNodes = NodeParser.parse(file: file)
        //Gets Node for the school
        let schoolNode:SCNNode = gameScene.rootNode.childNode(withName: "School", recursively: false)!
        //Iterates over each node to determine which floor it is on
        for n in allNodes {
            if let sn1:SCNNode = schoolNode.childNode(withName: "Floor1", recursively: false)?.childNode(withName: "Nodes1", recursively: false)?.childNode(withName: n.name, recursively: false){
                n.position = sn1.getPositionFromGeometry()//marker.worldPosition
                
                //print(sn1.position)
                n.floor = 1
                n.sceneNode = sn1
                //Changes Node color to clear
                sn1.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                floor1Nodes.append(n)
            }
            else if let sn2:SCNNode = schoolNode.childNode(withName: "Floor2", recursively: false)?.childNode(withName: "Nodes2", recursively: false)?.childNode(withName: n.name, recursively: false){
                n.position = sn2.getPositionFromGeometry()
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
        Global.nodes = [floor1Nodes, floor2Nodes]
        
//        var fileStr = ""
//        var curFloor = 1
//        for floor in Global.nodes {
//            for node in floor {
//                fileStr += "%\(node.name)\n"
//                fileStr += "x\(node.position.x)\n"
//                fileStr += "y\(node.position.z)\n"
//                fileStr += "f\(curFloor)\n"
//                for connection in node.strConnections {
//                    fileStr += "-\(connection)\n"
//                }
//                for room in node.rooms {
//                    fileStr += "@\(room)\n"
//                }
//            }
//            curFloor += 1
//        }
        
//        let fileManager = FileManager.default
//        do{
//            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let fileURL = documents.appendingPathComponent("nodes.dat")
//            print(fileURL)
//            try fileStr.write(to: fileURL, atomically: true, encoding: .ascii)
//        }catch{
//            print("Did Not Write")
//        }
    }
    
    /*Gets All Rooms from nodes */
    func initRooms(){
        var rooms:[String] = []
        for floorArray:[Node] in Global.nodes {
            for node:Node in floorArray {
                for room in node.rooms {
                    rooms.append(room)
                }
            }
        }
        Global.rooms = rooms
    }
    
    func initStructures() {
        let stuctures:[[SCNNode]] = [(gameScene.rootNode.childNode(withName: "Structures1", recursively: true)?.childNodes)!, (gameScene.rootNode.childNode(withName: "Structures2", recursively: true)?.childNodes)!]
        var file = "fallback"
        if let f = UserDefaults.standard.object(forKey: "colors") as? String {
            file = f
        }
        Global.structures = StructureParser.parseStructures(file, structureNodes: stuctures)
    }
    
    func initStairs(){
        var file = "fallback"
        if let f = UserDefaults.standard.object(forKey: "stairs") as? String {
            file = f
        }
        let stairs = StairParser.parseStairs(file)
        var validStairs:[Stair] = []
        for stair in stairs{
            var mapCheck = false
            var nodeCheck = false
            if let stairNode = gameScene.rootNode.childNode(withName: stair.name, recursively: true){
                stairNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                mapCheck = true
            }
            else{
                print("Stair Not Found\(stair.name)")
            }
            
            for floor in Global.nodes{
                for node in floor{
                    if node.name == stair.entryStr{
                        stair.entryNode = node
                        stair.floor = node.floor
                        nodeCheck = true
                        break
                    }
                }
            }
            if(!nodeCheck){
                print("Node not found: \(stair.entryStr) for stair: \(stair.name)")
            }
            if mapCheck && nodeCheck {
                validStairs.append(stair)
            }
        }
        for stair in validStairs {
            for cStair in validStairs {
                if stair.name != cStair.name && stair.id == cStair.id {
                    stair.complementary = cStair
                    break
                }
            }
        }
        Global.stairs = validStairs
    }
    
    func initStaff(){
        var file = "fallback"
        if let f = UserDefaults.standard.object(forKey: "staff") as? String {
            file = f
        }
        StaffParser.parseStaff(file)
        for s in Global.staff {
            for c in Global.classes {
                if s.classIds.contains(c.id){
                    s.classes.append(c)
                    c.staff = s
                }
            }
        }
    }
    
    func resizeOverlay(_ size: OverlaySize) {
        var newBottomConstant = bottomConstant
        switch size {
        case .Large:
            newBottomConstant = -20
            break
        case .xMedium:
            newBottomConstant = -200
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
        switchVisiblePath(floor)
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
        
        for label in roomLabels[floor - 1] {
            label.isHidden = false
        }
        for label in roomLabels[(floor == 1) ? 1 : 0] {
            label.isHidden = true
        }
    }
    
    func startNavigation(_ session: NavigationSession) {
        currentNavSession = session
        guard let path = Pathfinder.search(start: session.start, end: session.end, useElevator: session.usesElevators) else{
            return
        }
        floorSelect.setFloor(session.start.floor)
        var makeVisible = true
        for p in path {
            let line = drawPath(p, radius: 0.1, color: (makeVisible) ? UIView().tintColor : UIColor.clear)
            currentNavSession?.lines[p[0].floor] = line
            makeVisible = false
        }
        removeHighlights()
        if let s = Global.structures.searchForStructure((currentNavSession?.startStr)!){
            highlight(room: s)
        }
        if let s = Global.structures.searchForStructure((currentNavSession?.endStr)!){
            highlight(room: s)
        }
//        if currentNavSession?.startStr
//        for room in (currentNavSession?.start.rooms)! {
//            if let s = Global.structures.searchForStructure(room){
//                highlight(room: s)
//                break
//            }
//        }
//        for room in (currentNavSession?.end.rooms)! {
//            if let s = Global.structures.searchForStructure(room){
//                highlight(room: s)
//                break
//            }
//        }
        camera?.showWholeMap()
        
        
        overlayController?.reset()
        routeBar.changeRooms(session)
        routeBottomAnchor.constant = -15
        leftAnchor.constant = -300
        UIView.animate(withDuration: 0.5) {
            self.gameView.layoutIfNeeded()
        }
        
    }
    
    func endRoute(){
        leftAnchor.constant = 20
        routeBottomAnchor.constant = 100
        UIView.animate(withDuration: 0.5) {
            self.gameView.layoutIfNeeded()
        }
        removeHighlights()
        if let line = currentNavSession?.lines[1] {
            for n in line {
                n.removeFromParentNode()
            }
        }
        if let line = currentNavSession?.lines[2] {
            for n in line {
                n.removeFromParentNode()
            }
        }
        resizeOverlay(.Large)
        currentNavSession = nil
    }
    func switchVisiblePath(_ floor:Int){
        if let session = currentNavSession {
            for ml in session.lines.values {
                for l in ml {
                    l.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                }
            }
            if let lines = session.lines[floor] {
                for line in lines {
                    line.geometry?.firstMaterial?.diffuse.contents = UIView().tintColor
                }
            }
        }
        
    }
    
    func drawPath(_ path:[Node], radius:CGFloat, color:UIColor) -> [SCNNode]{
        var nodesAdded:[SCNNode] = []
        var prev:Node? = nil
        for n in path {
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = n.position
            gameScene.rootNode.addChildNode(sphereNode)
            nodesAdded.append(sphereNode)
            if prev == nil {
                prev = n
                continue
            }
            let lineNode = SCNNode().buildLineInTwoPointsWithRotation(from: (prev?.position)!, to: n.position, radius: radius, color: color)
            gameScene.rootNode.addChildNode(lineNode)
            nodesAdded.append(lineNode)
            prev = n
        }
        return nodesAdded
    }
    
    func highlight(room:Structure){
        let mat = SCNMaterial()
        mat.diffuse.contents = room.node.geometry?.firstMaterial?.diffuse.contents as! UIColor
        mat.emission.contents = UIColor.cyan
        room.node.scale.y += 0.2
        room.node.geometry?.materials[0] = mat
        highlightedRooms.append(room)
        let highlighAnim = CABasicAnimation(keyPath: "geometry.firstMaterial.emission.contents")
        highlighAnim.fromValue = UIColor.cyan
        highlighAnim.toValue = UIColor.clear
        highlighAnim.duration = 1
        highlighAnim.repeatCount = .infinity
        highlighAnim.autoreverses = true
        room.node.addAnimation(highlighAnim, forKey: "glow")
    }
    
    func removeHighlights(){
        for s in highlightedRooms{
            s.node.removeAnimation(forKey: "glow")
            s.node.geometry?.firstMaterial?.emission.contents = UIColor.clear
            s.node.scale.y -= 0.2
        }
        highlightedRooms = []
    }
    
    func displayLabels(){
        var allLocations:[String:LabelLocation] = [:]
        for room in Global.rooms {
            if room == "Bathroom" {
                continue
            }
            if let s = Global.structures.searchForStructure(room) {
                let labelLocation = LabelLocation(rooms: s.name, isStructure: true, structure: s, node: nil)
                
                if !allLocations.values.contains(labelLocation) {
                    allLocations[room] = labelLocation
                }
                else{
                    print("Duplicate(Structure) \(s.name)")
                }
                
                
            }else if let n = Global.nodes.searchForByRoom(room){
                let labelLocation = LabelLocation(rooms: n.rooms,isStructure: false, structure: nil, node: n)
                
                if !allLocations.values.contains(labelLocation) {
                    allLocations[room] = labelLocation
                }else{
                    print("Duplicate(Node) \(n.rooms)")
                }
                
            }else{
                print("No Node or Structure For \(room)")
            }
        }
        var labels:[[SCNNode]] = [[], []]
        for location in allLocations.values {
            var room = location.rooms[0]
            for r in location.rooms {
                if r.count > room.count {
                    room = r
                }
            }
            
            let text = SCNText(string: room, extrusionDepth: 0)
            text.font = UIFont.boldSystemFont(ofSize: 0.25)
            text.firstMaterial?.diffuse.contents = UIColor.black
            
            
            let node = SCNNode(geometry: text)
            node.constraints = [SCNBillboardConstraint()]
            
            let (min, max) = node.boundingBox
            node.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, (max.y - min.y) / 2 + min.y, 0)
            
            
            
            gameScene.rootNode.addChildNode(node)
            node.position = location.getLocation()
            node.position.y = (location.getFloor() == 1) ? 0 : 0.7
            
            if room.count > 12 {
                node.position.z += 0.3
            }
            
            
            node.isHidden = (location.getFloor() == 1) ? false : true
            labels[location.getFloor() - 1].append(node)
        }
        roomLabels = labels
        updateLabelDisplay()
        
    }
    
    func openSchedule() {
        let cont = UINavigationController(rootViewController: ScheduleController())
        cont.modalPresentationStyle = .formSheet
        present(cont, animated: true, completion: nil)
    }
    func openStaffFinder() {
        let cont = UINavigationController(rootViewController: StaffSearchController())
        cont.modalPresentationStyle = .formSheet
        present(cont, animated: true, completion: nil)
    }
    
    func openSettings() {
        let cont = UINavigationController(rootViewController: SettingsController())
        cont.modalPresentationStyle = .formSheet
        present(cont, animated: true, completion: nil)
    }
    
    @objc
    func updateLabelDisplay() {
        let shouldDisplay:Bool = UserDefaults.standard.bool(forKey: "displayRoomLabels")
        for floor in roomLabels {
            for label in floor {
                label.geometry?.firstMaterial?.diffuse.contents = shouldDisplay ? UIColor.black : UIColor.clear
            }
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
        zAlign.eulerAngles.x = Float(Double.pi / 2)
        
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

struct LabelLocation:Equatable {
    
    static func == (lhs: LabelLocation, rhs: LabelLocation) -> Bool {
        if lhs.isStructure != rhs.isStructure {
            return false
        }
        for lRoom in lhs.rooms {
            if lRoom == "Bathroom" {
                continue
            }
            for rRoom in rhs.rooms {
                if lRoom == rRoom {
                    return true
                }
            }
        }
        return false
    }
    let rooms:[String]
    let isStructure:Bool
    let structure:Structure?
    let node:Node?
    
    func getLocation() -> SCNVector3 {
        if isStructure {
            return (structure?.node.getPositionFromGeometry())!
        }else{
            return (node?.position)!
        }
    }
    func getFloor() -> Int {
        if isStructure {
            return (structure?.floor)!
        }else{
            return (node?.floor)!
        }
    }
}
