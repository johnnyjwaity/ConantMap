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
import MapKit
import SystemConfiguration.CaptiveNetwork
import CoreData

class MapViewController: UIViewController, SCNSceneRendererDelegate, OverlayDelegate, FloorSelectDelegate, RouteBarDelegate, OptionsDelegate, CLLocationManagerDelegate {
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Scene View Variables
    static var main:MapViewController? = nil
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var camera:Camera? = nil
    
    // UI Left Overlay Variables
    var overlayController:OverlayController? = nil
    var bottomAnchor:NSLayoutConstraint? = nil
    var heightAnchor:NSLayoutConstraint? = nil
    var leftAnchor:NSLayoutConstraint!
    var bottomConstant:CGFloat = 0
    
    //Route Bar Variables
    var routeBar:RouteController!
    var routeBottomAnchor:NSLayoutConstraint!
    
    //Floor Select Varaibles
    var floorSelect:FloorSelectController!
    
    //Navigation Variables + Map Configuration
    var currentNavSession:NavigationSession? = nil
    var highlightedRooms:[Structure] = []
    var roomLabels:[[SCNNode]]!
    var lastPath:[[Node]]!
    var wordPath:[Node:WalkDirection]!
    var subDirections:[Node:String]!
    
    //Location Varaibles
    let locationManager = CLLocationManager()
    var gpsPoints:[SCNNode] = []
    let gpsCoordinates = [[42.035705, -88.064329], [42.036693, -88.061544], [42.037123, -88.062951]]
    var scale:[Double]!
    var macLabel:UILabel!
    var currentLocationFloor = 1
    let banner = DirectionBanner()
    var macLocations:[MacLocation]!
    var lastAddress:MacAddress? = nil
    var locationType = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set shared Instance
        MapViewController.main = self
        // Map Intialization
        initView()
        initScene()
        initNodes()
        initRooms()
        initStructures()
        initStairs()
        initStaff()
        initMacAddresses()
        //UI Intialization
        setUpView()
        
        displayLabels()
        changeFloor(1)
        
        
        gameView.addSubview(banner)
        banner.topConstraint = banner.topAnchor.constraint(equalTo: gameView.topAnchor, constant: -100)
        banner.topConstraint.isActive = true
        banner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        if UIDevice.isIPad() {
            banner.widthAnchor.constraint(equalToConstant: 450).isActive = true
        }else{
            banner.widthAnchor.constraint(equalTo: gameView.widthAnchor, multiplier: 0.9).isActive = true
        }
        banner.heightAnchor.constraint(equalToConstant: 100).isActive = true
        banner.isDisplayed = false
        
        
        //Create Mac Address Label
        macLabel = UILabel()
        macLabel.translatesAutoresizingMaskIntoConstraints = false
        macLabel.numberOfLines = 3
        macLabel.backgroundColor  = UIColor.white
        gameView.addSubview(macLabel)
        macLabel.bottomAnchor.constraint(equalTo: gameView.bottomAnchor).isActive = true
        macLabel.rightAnchor.constraint(equalTo: gameView.rightAnchor).isActive = true
        macLabel.textAlignment = .right
        
        if UserDefaults.standard.object(forKey: "location") == nil {
            UserDefaults.standard.set(1, forKey: "location")
        }
        locationType = UserDefaults.standard.integer(forKey: "location")
        //Listen for Settings Updates to reflect in map
        //Label Listener
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabelDisplay), name: Notification.Name("ChangeRoomLabelDispaly"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocationType), name: Notification.Name("ChangeLocationType"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissAllControllers), name: Notification.Name("Dismiss All"), object: nil)
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
//        gameView.addGestureRecognizer(pan)
        
        //Set up GPS
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.headingOrientation = getOrientation()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        //Monitor Mac Address Changes
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            let wifiInfo = self.getWIFIInformation()
            if wifiInfo["SSID"] == "D211-Mobile" {
                var bssid = wifiInfo["BSSID"]!//String((wifiInfo["BSSID"]!).filter{!":".contains($0)})
                var components = bssid.components(separatedBy: ":")
                var counter = 0
                for c in components {
                    if c.count == 1 {
                        components[counter] = "0" + components[counter]
                    }
                    counter += 1
                }
                bssid = components.joined()
                let macAddress = Global.macAddresses.searchWithAddress(bssid)
                if let address = macAddress {
//                    DispatchQueue.main.async {
//                        let text = "BSSID: \(MacAddress.readable(bssid))\nMAC Address: \(MacAddress.readable(address.address))\nName: \(address.name)"
//                        self.macLabel.text = text
//                    }
                    for macLoc in self.macLocations {
                        if macLoc.name == address.name {
                            self.currentLocationFloor = macLoc.floor
                            let locationNode = self.gameScene.rootNode.childNode(withName: "location", recursively: false)!
//                            if self.locationType != 0 {
                                if self.floorSelect.getFloor() != self.currentLocationFloor {
                                    locationNode.opacity = 0
                                }else{
                                    locationNode.opacity = 1
                                }
//                            }
                            
                            if true{
//                                print("set mac")
                                if address.name != self.lastAddress?.name {
                                    if self.locationType == 1 || self.locationType == 3 {
                                        self.moveLocationMarker(x: Float(macLoc.x), y: Float(macLoc.y))
                                    }
                                }
                            }
                            break
                        }
                    }
                    self.lastAddress = address
                }else{
                    DispatchQueue.main.async {
                        let text = "BSSID: \(bssid)\nMAC Address: NONE FOUND\nName: NONE FOUND"
                        self.macLabel.text = text
                    }
                }
                
            }
        }
        
    }
    var startPoint:SCNVector3!
    @objc
    func panned(_ gesture:UIPanGestureRecognizer){
        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: false)
        switch gesture.state {
        case .began:
            startPoint = locationNode?.position
            break
        case .changed:
            locationNode?.position = startPoint + SCNVector3(Double(gesture.translation(in: gameView).x) / 10, 0, Double(gesture.translation(in: gameView).y) / 10)
        case .ended:
            startPoint = locationNode?.position
        default:
            break
        }
    }
    // Uses Captive Network Framework in order to retrieve SSID and BSSID
    func getWIFIInformation() -> [String:String]{
        var informationDictionary = [String:String]()
        let informationArray:NSArray? = CNCopySupportedInterfaces()
        
        
        
        if let information = informationArray {
            let dict:NSDictionary? = CNCopyCurrentNetworkInfo(information[0] as! CFString)
            if let temp = dict {
                informationDictionary["SSID"] = "\(temp["SSID"]!)"
                informationDictionary["BSSID"] = "\(temp["BSSID"]!)"
                return informationDictionary
            }
        }
        
        
        return informationDictionary
    }
    // Heading Update Implementation from CLLocationManagerDelegate Protocol
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        manager.headingOrientation = getOrientation()
        //Update rotation based on heading
        gameScene.rootNode.childNode(withName: "location", recursively: false)?.eulerAngles.y = -(Float(newHeading.magneticHeading) * (Float.pi / 180))
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return false
    }
    // Location update Implementation from CLLocationManagerDelegate Protocol
    var lastGPSX:Float? = nil
    var lastGPSY:Float? = nil
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0].altitude)
        print("updateing location")
//        DispatchQueue.main.async {
//            self.macLabel.text = "\(locations[0].altitude)"
//        }
        // Init GPS Points Array if is empty
        /*
         Three GPS poitns are on the scene view in these points are used to translate coordinates into pixel position with
         triangualrization
         */
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
        }
        if true{
            print("LOCATION")
            // Get Latitude and Logitude from CLLocation
            let currentLat = (locations.last?.coordinate.latitude)!
            let currentLong = (locations.last?.coordinate.longitude)!
//            print(currentLat)
//            print(currentLong)
            
            // gpsCoordinates contains the coordinates for each of the GPS Points. These are static coordinates for static locations
            //Get distance in coordinates between GPSPoint 1 and GPS Point 2. Distance is calcualted with the Haversine Formaula in order to get accurate distance readings from coordinates. Haversine takes into account Earth Curvature.
            let coordDistance = haversine(x1: gpsCoordinates[0][0], y1: gpsCoordinates[0][1], x2: gpsCoordinates[1][0], y2: gpsCoordinates[1][1])
            //Get Pixel distance betewen GPSPoint 1 and GPSPoint 2 these disatnces are static and will not change
            let pixelDisatnce = distance(x1: Double(gpsPoints[0].position.x), y1: Double(gpsPoints[0].position.z), x2: Double(gpsPoints[1].position.x), y2: Double(gpsPoints[1].position.z))
            
            //Meters to Pixel Conversion Number
            let pixelsToCoords = pixelDisatnce / coordDistance
//            print(pixelsToCoords)
            
            //Get Dustances from GPSPoints to Current Location. Not static distances Unlike other ones. Once again uses Haversine formaula in order to get accurate readings
            let d1c = haversine(x1: currentLat, y1: currentLong, x2: gpsCoordinates[0][0], y2: gpsCoordinates[0][1])
            let d2c = haversine(x1: currentLat, y1: currentLong, x2: gpsCoordinates[1][0], y2: gpsCoordinates[1][1])
            let d3c = haversine(x1: currentLat, y1: currentLong, x2: gpsCoordinates[2][0], y2: gpsCoordinates[2][1])
            
            // COnvert meter distanee from coordinate distance into pixel distances
            let d1p = d1c * pixelsToCoords
            let d2p = d2c * pixelsToCoords
            let d3p = d3c * pixelsToCoords
            
            // Gets Intersection points from gps point 1 and two. Circes are created areound the points with radius of the ditance it is to the current location. the poiunts array contains two one or zero points based on where the circles intersect.
            let points = circleIntersection(x1: Double(gpsPoints[0].position.x), y1: Double(gpsPoints[0].position.z), r1: d1p, x2: Double(gpsPoints[1].position.x), y2: Double(gpsPoints[1].position.z), r2: d2p)
            
            // Get distance from the circle intersection points to the thord gps point in order to determine the users location.
            let p1d = distance(x1: points[0], y1: points[1], x2: Double(gpsPoints[2].position.x), y2: Double(gpsPoints[2].position.z))
            let p2d = distance(x1: points[2], y1: points[3], x2: Double(gpsPoints[2].position.x), y2: Double(gpsPoints[2].position.z))
            
            // DIfferences between the points
            let difference1 = abs(p1d - d3p)
            let difference2 = abs(p2d - d3p)

            var x:Float
            var y:Float
            if difference1 <= difference2 {
                x = Float(points[0])
                y = Float(points[1])
            }else{
                x = Float(points[2])
                y = Float(points[3])
            }
            if x != lastGPSX || y != lastGPSY{
                if locationType == 1 || locationType == 2 {
                    moveLocationMarker(x: x, y: y)
                }
            }
            lastGPSX = x
            lastGPSY = y
            
        }
        
        
    }
    var movingMarker = false
    func moveLocationMarker(x:Float, y:Float){
//        return
        if movingMarker {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                self.moveLocationMarker(x: x, y: y)
            }
            return
        }
        
        
        movingMarker = true
        
        // Animate the moving of the location marker in order to make smooth transitions
        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: false)!
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = locationNode.position
        animation.toValue = SCNVector3(x, locationNode.position.y, y)
        animation.duration = 0.2
        animation.repeatCount = 0
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        locationNode.addAnimation(animation, forKey: "move")
        //Set permanent location after the animation is complete
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
            locationNode.position = SCNVector3(x, locationNode.position.y, y)
            self.movingMarker = false
        }
    }
    
    // Distance Formula
    func distance(x1:Double, y1:Double, x2:Double, y2:Double) -> Double{
        return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
    }
    // Haversine Formula FUnciton
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
    
    // Circle INtersection calcualtor
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
    
    
    
    func initView(){
        // Create SceneVIew For Map
        let sV = SCNView(frame: UIScreen.main.bounds)
        view.addSubview(sV)
        gameView = sV
        gameView.autoenablesDefaultLighting = true;
        gameView.delegate = self
    }
    
    func initScene() {
        // Loads Scene File (The Map) To display
        guard let s = SCNScene(named: "art.scnassets/Map.scn")
            else{fatalError("NO Load")}
        gameScene = s
        gameView.scene = gameScene
        gameView.isPlaying = true;
        camera = Camera(gameScene)
    }
    
    //Sets up
    func setUpView(){
        // Create Overlay
        overlayController = OverlayController()
        // Set Overlay Delegate
        overlayController?.delegate = self
        let overlay:UIView = (overlayController?.view)!
        gameView.addSubview(overlay)
        overlay.layer.zPosition = 2
        // Set Constraints + save in order to move it later
        if UIDevice.isIPad() {
            bottomConstant = -20
            leftAnchor = overlay.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 20)
            leftAnchor.isActive = true
            overlay.topAnchor.constraint(equalTo: gameView.topAnchor, constant: 20).isActive = true
            bottomAnchor = overlay.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: bottomConstant)
            bottomAnchor?.isActive = true
            overlay.widthAnchor.constraint(equalToConstant: 300).isActive = true
            
        }else{
            bottomConstant = 200
            bottomAnchor = overlay.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: 25)
            bottomAnchor?.isActive = true
            heightAnchor = overlay.heightAnchor.constraint(equalToConstant: 200)
            heightAnchor?.isActive = true
            overlay.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10 /*< 300 ? UIScreen.main.bounds.width : 300*/).isActive = true
            overlay.centerXAnchor.constraint(equalTo: gameView.centerXAnchor).isActive = true
        }
        // Add resizeable Drag Bar to Overlay View
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        overlayController?.dragBar.addGestureRecognizer(pan)
        
        // Create a Route Bar
        routeBar = RouteController()
        routeBar.delegate = self
        self.addChild(routeBar)
        gameView.addSubview(routeBar.view)
        routeBottomAnchor = routeBar.view.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: UIDevice.isIPad() ? 100 : 150)
        routeBottomAnchor.isActive = true
        routeBar.view.widthAnchor.constraint(equalTo: gameView.widthAnchor, multiplier: UIDevice.isIPad() ? 0.6 : 1).isActive = true
        routeBar.view.heightAnchor.constraint(equalToConstant: UIDevice.isIPad() ? 100 : 150).isActive = true
        routeBar.view.centerXAnchor.constraint(equalTo: gameView.centerXAnchor).isActive = true
        routeBar.setupView(NavigationSession(start: "180", end: "280", usesElevators: false))
        
        // Create Floor Select View
        floorSelect = FloorSelectController()
        floorSelect.delegate = self
        addChild(floorSelect)
        gameView.addSubview(floorSelect.view)
        floorSelect.view.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -20).isActive = true
        floorSelect.view.topAnchor.constraint(equalTo: gameView.topAnchor, constant: UIDevice.isIPad() ? 20 : 20).isActive = true
        floorSelect.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floorSelect.view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //Current Location Button
        let currentLocationButton = UIButton(type: .system)
        currentLocationButton.backgroundColor = UIColor.white
        currentLocationButton.layer.cornerRadius = 12
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationButton.setImage(#imageLiteral(resourceName: "target2").withRenderingMode(.alwaysTemplate), for: .normal)
        currentLocationButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        currentLocationButton.addTarget(self, action: #selector(panToCurrentLocation), for: .touchUpInside)
        gameView.addSubview(currentLocationButton)
        currentLocationButton.topAnchor.constraint(equalTo: floorSelect.view.bottomAnchor, constant: 20).isActive = true
        currentLocationButton.centerXAnchor.constraint(equalTo: floorSelect.view.centerXAnchor).isActive = true
        currentLocationButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentLocationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Create OPtions View (Schedule, Teacher Search, Settings)
        let optionController = OptionsController()
        optionController.delegate = self
        optionController.view.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(optionController.view)
        addChild(optionController)
        optionController.view.widthAnchor.constraint(equalTo: floorSelect.view.widthAnchor).isActive = true
        optionController.view.heightAnchor.constraint(equalToConstant: 132.5).isActive = true
        if UIDevice.isIPad() {
            optionController.view.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 20).isActive = true
            optionController.view.centerXAnchor.constraint(equalTo: floorSelect.view.centerXAnchor).isActive = true
        }else{
            optionController.view.topAnchor.constraint(equalTo: gameView.topAnchor, constant: 20).isActive = true
            optionController.view.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 20).isActive = true
        }
        
        
        gameView.bringSubviewToFront(overlay)
        // Add Pan Recongnizers to the Sceen.
        let gamePan = UIPanGestureRecognizer(target: self, action: #selector(handleCameraMove(gesture:)))
        gameView.addGestureRecognizer(gamePan)

        let zoom = UIPinchGestureRecognizer(target: self, action: #selector(handleCameraZoom(gesture:)))
        gameView.addGestureRecognizer(zoom)

    }
    
    @objc
    func handleCameraMove(gesture:UIPanGestureRecognizer){
        // Move Camera When Panning
        camera?.move(gesture.velocity(in: gameView), state: gesture.state, numOfTouches: gesture.numberOfTouches)
    }
    @objc
    func handleCameraZoom(gesture:UIPinchGestureRecognizer) {
        // Zoom Camera when panning
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
    // Change size of Overaly COntroller if drag bar is apnned on
    @objc
    func handlePan(gesture:UIGestureRecognizer){
        let panGesture:UIPanGestureRecognizer = gesture as! UIPanGestureRecognizer
        let translation = panGesture.translation(in: gameView)
        switch panGesture.state {
        case .began:
            break
        case .changed:
            (UIDevice.isIPad() ? bottomAnchor : heightAnchor)?.constant = bottomConstant + (translation.y * (UIDevice.isIPad() ? 1 : -1))
            break
        case .ended:
            bottomConstant = ((UIDevice.isIPad() ? bottomAnchor : heightAnchor)?.constant)!
            break
        default:
            break
        }
    }
    @objc
    func panToCurrentLocation(){
        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: true)!
        if abs(locationNode.position.x) > 100 || abs(locationNode.position.z) > 100 {
            return
        }
        floorSelect.setFloor(currentLocationFloor)
        camera?.panToPosition(locationNode.position, type: .Node, room: nil, floor: currentLocationFloor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //Update canera Motion
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
        
        //Strips Away Bad Connections
//        for node in allNodes {
//            if node.name == "N_103" {
//                var brokeAllConnections = false
//                while !brokeAllConnections {
//                    for c in node.connections {
//                        for c2 in node.connections {
//                            if c == c2 {
//                                continue
//                            }
//                            let angle = findAngle(p0: CGPoint(x: Double(c.position.x), y: Double(c.position.z)), p1: CGPoint(x: Double(node.position.x), y: Double(node.position.z)), p2: CGPoint(x: Double(c2.position.x), y: Double(c2.position.z)))
//                            print("\(angle) \(c.name) \(c2.name)")
//
//                        }
//                    }
//                    brokeAllConnections = true
//                }
//
//            }
//        }
        for floor in Global.nodes {
            for node in floor {
                var removedAllConnections = false
                connectionLoop: while !removedAllConnections {
                    for c in node.connections {
                        for c2 in node.connections {
                            if c == c2 {
                                continue
                            }
                            let angle = findAngle(p0: CGPoint(x: Double(c.position.x), y: Double(c.position.z)), p1: CGPoint(x: Double(node.position.x), y: Double(node.position.z)), p2: CGPoint(x: Double(c2.position.x), y: Double(c2.position.z)))
                            if abs(angle) < 10 {
                                if node.position.distance(receiver: c.position) < node.position.distance(receiver: c2.position) {
                                    node.connections.remove(at: node.connections.firstIndex(of: c2)!)
                                    node.strConnections.remove(at: node.strConnections.firstIndex(of: c2.name)!)
                                    c2.connections.remove(at: c2.connections.firstIndex(of: node)!)
                                    c2.strConnections.remove(at: c2.strConnections.firstIndex(of: node.name)!)
                                }else{
                                    node.connections.remove(at: node.connections.firstIndex(of: c)!)
                                    node.strConnections.remove(at: node.strConnections.firstIndex(of: c.name)!)
                                    c.connections.remove(at: c.connections.firstIndex(of: node)!)
                                    c.strConnections.remove(at: c.strConnections.firstIndex(of: node.name)!)
                                }
//                                print("Broke Connection")
                                continue connectionLoop
                            }
                        }
                    }
                    removedAllConnections = true
                }
            }
        }
        
        
        for n in allNodes {
            for c in n.connections {
                if !c.connections.contains(n) {
                    print("\(c.name) does not contain \(n.name)")
                }
            }
        }
        struct SimplePosition:Codable {
            let x:Float
            let y:Float
        }
        struct SimpleNode:Codable{
            let name:String
            let position:SimplePosition
            let floor:Int
            let connections:[String]
            let rooms:[String]
        }
        var simpleNodes:[SimpleNode] = []
        for i in 0..<Global.nodes.count {
            for node in Global.nodes[i] {
                let position = SimplePosition(x: node.position.x, y: node.position.z)
                let simpleNode = SimpleNode(name: node.name, position: position, floor: i, connections: node.strConnections, rooms: node.rooms)
                simpleNodes.append(simpleNode)
            }
        }
        do{
            let data = try JSONEncoder().encode(simpleNodes)
            let jsonString = String(data: data, encoding: .utf8)!
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("nodes.json")
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Exported Nodes")
        }catch {
            print("Node Export Failure")
        }
        
        
        // Following Code Exports FIle with Node Locations included
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
//
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
    
    func findAngle(p0:CGPoint, p1:CGPoint, p2:CGPoint) -> CGFloat {
        let a = pow(p1.x - p0.x, 2) + pow(p1.y - p0.y, 2)
        let b = pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)
        let c = pow(p2.x - p0.x, 2) + pow(p2.y - p0.y, 2)
        var cosPart:CGFloat = (a + b - c)
        cosPart /= sqrt(4 * a * b)
        return acos(cosPart) * (180 / CGFloat.pi)
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
    // Get all geometry for structures so highlighting can be changed
    func initStructures() {
        let stuctures:[[SCNNode]] = [(gameScene.rootNode.childNode(withName: "Structures1", recursively: true)?.childNodes)!, (gameScene.rootNode.childNode(withName: "Structures2", recursively: true)?.childNodes)!]
        var file = "fallback"
        if let f = UserDefaults.standard.object(forKey: "colors") as? String {
            file = f
        }
        Global.structures = StructureParser.parseStructures(file, structureNodes: stuctures)
    }
    // Load stair data into map
    func initStairs(){
        // Get Stair file
        var file = "fallback"
        if let f = UserDefaults.standard.object(forKey: "stairs") as? String {
            file = f
        }
        let stairs = StairParser.parseStairs(file)
        // Prepare array for stars
        var validStairs:[Stair] = []
        for stair in stairs{
            var mapCheck = false
            var nodeCheck = false
            // Check to see if satir exists on map
            if let stairNode = gameScene.rootNode.childNode(withName: stair.name, recursively: true){
                stairNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                stair.postion = stairNode.getPositionFromGeometry()
                mapCheck = true
            }
            else{
                print("Stair Not Found\(stair.name)")
            }
            // CHeck to see if stair has a node associated with it
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
            // Allow stair to be used if passed both tests
            if mapCheck && nodeCheck {
                validStairs.append(stair)
            }
        }
        // Set other stair (from diffferent floor)
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
    // Retrieve staff information
    func initStaff(){
        let staffData = Staff.load()
        Global.staff = staffData.staff
        Global.classes = staffData.classes
    }
    // Load Mac Address Data into project
    func initMacAddresses(){
        //load mac address data into project
        var parseSuccesful = false
        if let macData = UserDefaults.standard.value(forKey: "mac-addresses") as? Data {
            let macAddressesParse = try? PropertyListDecoder().decode(Array<MacAddress>.self, from: macData)
            if let macAddresses = macAddressesParse {
                Global.macAddresses = macAddresses
                parseSuccesful = true
            }
        }
        // If parse failed or there was no mac address data saved.
        if !parseSuccesful {
            
            let macAddresses = MacAddressParser.parse()
            let macDataEncode = try? PropertyListEncoder().encode(macAddresses)
            if let macData = macDataEncode {
                UserDefaults.standard.set(macData, forKey: "mac-addresses")
            }
            Global.macAddresses = macAddresses
            
        }
        initMacLocations()
    }
    func initMacLocations(){
        do{
            let path = Bundle.main.path(forResource: "MacLocations", ofType: "json")
            
            var locations:[MacLocation] = try JSONDecoder().decode([MacLocation].self, from: Data(contentsOf: URL(fileURLWithPath: path!)))
            print(locations[0])
            print(locations[57])
            print(locations[62])
            print(locations[118])
            let mac107 = locations.searchForLocation("C-R-107.d211.org") //0
            let mac185 = locations.searchForLocation("C-R-185.d211.org") //57
            let mac204 = locations.searchForLocation("C-R-204.d211.org") //62
            let mac286 = locations.searchForLocation("C-R-286.d211.org") //118
            
            
            let zeroXOffset = -locations[mac107].x
            let zeroYOffset = -locations[mac107].y
            let zeroXOffset2 = -locations[mac204].x
            let zeroYOffset2 = -locations[mac204].y
            for i in 0..<locations.count {
                if locations[i].floor == 1{
                    locations[i].x += zeroXOffset
                    locations[i].y += zeroYOffset
                }else{
                    locations[i].x += zeroXOffset2
                    locations[i].y += zeroYOffset2
                }
            }
            let struc107X = -10.273
            let struc107Y = 24.923
            let struc185X = 14.224
            let struc185Y = 12.798
            
            let struc204X = -8.854
            let struc204Y = 27.083
            let struc286X = 16.942
            let struc286Y = 12.747
            
            let xChange = locations[mac185].x - locations[mac107].x
            let yChange = locations[mac185].y - locations[mac107].y
            let actualXChange = struc185X - struc107X
            let actualYChange = struc185Y - struc107Y
            let xMultiplier = actualXChange / xChange
            let yMultiplier = actualYChange / yChange
            
            let xChange2 = locations[mac286].x - locations[mac204].x
            let yChange2 = locations[mac286].y - locations[mac204].y
            let actualXChange2 = struc286X - struc204X
            let actualYChange2 = struc286Y - struc204Y
            let xMultiplier2 = actualXChange2 / xChange2
            let yMultiplier2 = actualYChange2 / yChange2
            
            for i in 0..<locations.count {
                if locations[i].floor == 1 {
                    locations[i].x *= xMultiplier
                    locations[i].y *= yMultiplier
                }else{
                    locations[i].x *= xMultiplier2
                    locations[i].y *= yMultiplier2
                }
            }
            
            let xOffset = struc107X - locations[mac107].x
            let yOffset = struc107Y - locations[mac107].y
            
            let xOffset2 = struc204X - locations[mac204].x
            let yOffset2 = struc204Y - locations[mac204].y
            
            for i in 0..<locations.count {
                if locations[i].floor == 1 {
                    locations[i].x += xOffset
                    locations[i].y += yOffset
                }else{
                    locations[i].x += xOffset2
                    locations[i].y += yOffset2
                }
            }
            for i in 0..<locations.count {
                if locations[i].floor == 2 {
                    locations[i].y -= 0.5
                }
            }
            macLocations = locations
            //Debug Only
//            let mat = SCNMaterial()
//            mat.diffuse.contents = UIColor.orange
//            for l in locations {
//                if l.floor == 2 {
//                    continue
//                }
//                let node = SCNNode(geometry: SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0))
//                node.geometry?.firstMaterial = mat
//                node.position = SCNVector3(l.x, l.floor == 1 ? 0.2 : 0.6, l.y)
//                gameScene.rootNode.addChildNode(node)
//            }
        }catch{
            
        }
    }
    // CHnages size of the overlay controller based on preset sizes
    func resizeOverlay(_ size: OverlaySize) {
        var newBottomConstant = bottomConstant
        switch size {
        case .Large:
            newBottomConstant = UIDevice.isIPad() ? -20 : UIScreen.main.bounds.height * 0.8
            break
        case .xMedium:
            newBottomConstant = UIDevice.isIPad() ? -200 : 500
            
            break
        case .Medium:
            newBottomConstant = UIDevice.isIPad() ? -496.5 : 300
        case .Small:
            newBottomConstant = -688
            break
        }
        bottomConstant = newBottomConstant
        (UIDevice.isIPad() ? bottomAnchor : heightAnchor)?.constant = newBottomConstant
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    // Implementation of changeFloor from FloorSelectDelegate Protocol
    func changeFloor(_ floor: Int) {
        //Get Parent Nodes of all floor 1 and floor 2 objects
        let floor1Node = gameScene.rootNode.childNode(withName: "Floor1", recursively: true)!
        let floor2Node = gameScene.rootNode.childNode(withName: "Floor2", recursively: true)!
        //Switch line that is shown on the map
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
        // Hide show correct labels
        for label in roomLabels[floor - 1] {
            label.isHidden = false
        }
        for label in roomLabels[(floor == 1) ? 1 : 0] {
            label.isHidden = true
        }
        
        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: true)!
        if floor == 1 {
            locationNode.scale.y = 0.61
        }else{
            locationNode.scale.y = 3.836
        }
        if floor == currentLocationFloor {
            locationNode.opacity = 1
        }else{
            locationNode.opacity = 0
        }
    }
    
    /*
     
     */
 
 
    func startNavigation(_ session: NavigationSession) {
        currentNavSession = session
        //find path
        guard var path = Pathfinder.search(start: session.start, end: session.end, useElevator: session.usesElevators) else{
            return
        }
        
        subDirections = [:]
        for floor in path {
            for node in floor {
                for intersection in Global.intersections {
                    if intersection.node == node.name {
                        let startIndex = floor.index(of: node)! - 1
                        let endIndex = floor.index(of: node)! + 1
                        if startIndex < 0 || endIndex >= floor.count {
                            break
                        }
                        for p in intersection.paths {
                            if p.start == floor[startIndex].name && p.end == floor[endIndex].name {
                                subDirections[node] = p.message
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
        path = Pathfinder.simplifyPath(path)!
        if let startStruc = Global.structures.searchForStructure(session.startStr) {
            var startPos = startStruc.node.getPositionFromGeometry()
//            if startStruc.name.contains("Cafeteria"){
//                startPos.z = 21.1
//            }
            print(startPos)
            startPos.y = session.start.position.y
            print(startPos)
            let newNode = Node("Temp Start", id: 5000)
            newNode.position = startPos
            newNode.floor = session.start.floor
            var floorPath = path.first
            let xChange = abs(floorPath![1].position.x - floorPath![0].position.x)
            let zChange = abs(floorPath![1].position.z - floorPath![0].position.z)
            var originalDistance:Float = 0
            var newDistance:Float = 0
            if xChange > zChange {
                originalDistance = xChange
                newDistance = abs(floorPath![1].position.x - newNode.position.x)
            }else{
                originalDistance = zChange
                newDistance = abs(floorPath![1].position.z - newNode.position.z)
            }
            if (originalDistance < newDistance){
                floorPath?.insert(newNode, at: 0)
            }else{
                floorPath![0] = newNode
            }
            
            if let f = floorPath{
                path[0] = f
            }
            
            let possbilePoints = [SCNVector3(path[0][0].position.x, path[0][0].position.y, path[0][1].position.z),SCNVector3(path[0][1].position.x, path[0][0].position.y, path[0][0].position.z)]
            let closest = (possbilePoints[0].distance(receiver: session.start.position) < possbilePoints[1].distance(receiver: session.start.position)) ? possbilePoints[0] : possbilePoints[1]
            var fPath = path[0]
            let squareNode = Node("Square Start", id: 5005)
            squareNode.floor = fPath[0].floor
            squareNode.position = closest
            fPath.insert(squareNode, at: 1)
            path[0] = fPath
            subDirections[squareNode] = "Out of \(session.startStr)"
        }
        if let endStruc = Global.structures.searchForStructure(session.endStr){
            var endPos = endStruc.node.getPositionFromGeometry()
//            if endStruc.name.contains("Cafeteria"){
//                endPos.z = 21.1
//            }
            endPos.y = session.end.position.y
            let newNode = Node("Temp End", id: 5001)
            newNode.position = endPos
            newNode.floor = session.end.floor
            var floorPath = path.last
            
            let xChange = abs(floorPath![floorPath!.count - 2].position.x - floorPath![floorPath!.count - 1].position.x)
            let zChange = abs(floorPath![floorPath!.count - 2].position.z - floorPath![floorPath!.count - 1].position.z)
            var originalDistance:Float = 0
            var newDistance:Float = 0
            if xChange > zChange {
                originalDistance = xChange
                newDistance = abs(floorPath![floorPath!.count - 2].position.x - newNode.position.x)
            }else{
                originalDistance = zChange
                newDistance = abs(floorPath![floorPath!.count - 2].position.z - newNode.position.z)
            }
            if (originalDistance < newDistance){
                floorPath?.append(newNode)
            }else{
                floorPath![(floorPath?.count)! - 1] = newNode
            }
            
            if let f = floorPath{
                path[path.count - 1] = f
            }
            let lastNode = path[path.count - 1].last!
            let secondToLastNode = path[path.count - 1][ path[path.count - 1].count - 2]
            let point1 = SCNVector3(lastNode.position.x, lastNode.position.y, secondToLastNode.position.z)
            let point2 = SCNVector3(secondToLastNode.position.x, lastNode.position.y, lastNode.position.z)
            let closest = (point1.distance(receiver: session.end.position) < point2.distance(receiver: session.end.position)) ? point1 : point2
            var fPath = path[path.count - 1]
            let squareNode = Node("Square End", id: 5006)
            squareNode.floor = fPath[0].floor
            squareNode.position = closest
            fPath.insert(squareNode, at: fPath.count - 1)
            path[path.count - 1] = fPath
        }
        
        path = Pathfinder.simplifyPath(path)!
        // Get written instructions on path
        wordPath = Pathfinder.getDirections(path)
        //Save path
        lastPath = path
        //Change floor to start floor of path
        floorSelect.setFloor(session.start.floor)
        var makeVisible = true
        for p in path {
            let line = drawPath(p, radius: 0.1, color: (makeVisible) ? UIView().tintColor : UIColor.clear)
            currentNavSession?.lines[p[0].floor] = line
            makeVisible = false
        }
        //remvove current room highlights
        removeHighlights()
        //Highlight start and end rooms
        if let s = Global.structures.searchForStructure((currentNavSession?.startStr)!){
            highlight(room: s)
        }
        if let s = Global.structures.searchForStructure((currentNavSession?.endStr)!){
            highlight(room: s)
        }
        camera?.showWholeMap()
        
        // Rest the over controller so it shows the default view again
        overlayController?.reset()
        // Dispay Route Bar At bottom
        routeBar.changeRooms(session)
        routeBottomAnchor.constant = UIDevice.isIPad() ? -15 : 0
        // Animate dissmissal of overlay controller to the left
        if UIDevice.isIPad() {
            leftAnchor.constant = -300
        }else{
            heightAnchor?.constant = 200
            bottomAnchor?.constant = 200
        }
        UIView.animate(withDuration: 0.5) {
            self.gameView.layoutIfNeeded()
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            if self.currentNavSession != nil {
//                self.updateDirectionDisplay()
//                print(self.getCurrentLocation() as Any)
            }else{
                timer.invalidate()
            }
        }
        
        // Following code is for debugging purposes. Moves location Node along path
//        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: false)
//        locationNode?.position = lastPath[0][0].position
//        currentIndex = 1
//        self.followRoute()
        
    }
    let mainBounds:[[Point]:String] = [[Point(x: 3.461, y: 13.327), Point(x: 8.933, y: 18.677)]:"Gym", [Point(x: 17.79, y: 11.714), Point(x: 19.508, y: 19.159)]:"Atrium", [Point(x: -5.086, y: 20.294), Point(x: -0.593, y: 21.429)]:"Media Center", [Point(x: -7.049, y: 21.526), Point(x: -0.776, y: 23.64)]:"Media Center", [Point(x: -2.998, y: 23.916), Point(x: 1.579, y: 25.295)]:"Media Center", [Point(x: -16.509, y: 20.397), Point(x: -11.643, y: 24.514)]:"Auditorium"]
    
    func getCurrentLocation() -> String? {
        let currentFloor = currentLocationFloor
        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: false)!
        if currentFloor == 1{
            for key in mainBounds.keys {
                if withinBounds(point: locationNode.position, boundA: key[0], boundB: key[1]) {
                    return mainBounds[key]!
                }
            }
        }
        var closestStructure:Structure? = nil
        var closestDistance:Float? = nil
        for struc in Global.structures {
            if struc.floor != currentFloor {
                continue
            }
            var foundNon = false
            for name in struc.name {
                if name.contains("Non") || name.contains("Bathroom") {
                    foundNon = true
                    break
                }
            }
            if foundNon {
                continue
            }
            if struc.node.containedInGeometryBounds(locationNode.position) {
                return struc.name[0]
            }
            
            if closestStructure == nil {
                closestStructure = struc
                closestDistance = struc.node.getPositionFromGeometry().distance(receiver: locationNode.position)
            }else{
                let potentialDistance = struc.node.getPositionFromGeometry().distance(receiver: locationNode.position)
                if potentialDistance < closestDistance! {
                    closestStructure = struc
                    closestDistance = potentialDistance
                }
            }
        }
        if let c = closestStructure {
            return c.name[0]
        }
        return nil
    }
    func withinBounds(point:SCNVector3, boundA:Point, boundB:Point) -> Bool {
        if CGFloat(point.x) >= boundA.x && CGFloat(point.x) <= boundB.x && CGFloat(point.z) >= boundA.y && CGFloat(point.z) <= boundB.y {
            return true
        }
        return false
    }
    var testNodes:[SCNNode] = []
    func updateDirectionDisplay(){
        let pathIndex = lastPath[0][0].floor == currentLocationFloor ? 0 : 1
        if pathIndex >= lastPath.count {
            banner.hide()
            return
        }
        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: false)!
        var angle = locationNode.eulerAngles.y * (180.0 / Float.pi)
        while angle < 0 || angle >= 360 {
            if angle < 0 {
                angle += 360
            }else{
                angle -= 360
            }
        }
        let locationDirection = Axis.determineAxis(angle: angle)
        
        let sortedIntersections = wordPath.keys.sorted { (n1, n2) -> Bool in
            if n1.floor != currentLocationFloor {
                return false
            }
            if locationNode.position.distance(receiver: n1.position) < locationNode.position.distance(receiver: n2.position) {
                return true
            }
            return false
        }
        for node in testNodes {
            node.removeFromParentNode()
        }
        testNodes = []
        let node = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 0.5))
        node.position = sortedIntersections[0].position
        gameScene.rootNode.addChildNode(node)
        testNodes.append(node)
        if locationNode.position.distance(receiver: sortedIntersections[0].position) < 2 {
            if let intersectionIndex = lastPath[pathIndex].firstIndex(of: sortedIntersections[0]) {
                var lines = [[lastPath[pathIndex][intersectionIndex - 1], lastPath[pathIndex][intersectionIndex]]]
                if intersectionIndex + 1 < lastPath[pathIndex].count {
                    lines.append([lastPath[pathIndex][intersectionIndex], lastPath[pathIndex][intersectionIndex + 1]])
                }
                var lineDirections:[Axis] = []
                for line in lines {
                    lineDirections.append(Axis.determineAxis(first: line[0], last: line[1]))
                }
//                let lineDirections = [Axis.determineAxis(first: lines[0][0], last: lines[0][1]), Axis.determineAxis(first: lines[1][0], last: lines[1][1])]
                if lineDirections.count > 1 && (lineDirections[1] == locationDirection || lineDirections[1].opposite() == locationDirection) {
                    banner.update(lineDirections[1] == locationDirection ? WalkDirection.forward : WalkDirection.backward)
                }else{
                    banner.update(wordPath[sortedIntersections[0]] ?? WalkDirection.forward)
                    banner.updateSubDirection(subDirections[sortedIntersections[0]] ?? "")
                }
                banner.show()
            }else{
                banner.hide()
            }
        }else{
            var closestDistance:Float = 1000
            var line:[Node] = []
            for i in 1..<lastPath[pathIndex].count {
                let distance = distanceFromPoint(p: locationNode.position.toCGPoint(), toLineSegment: lastPath[pathIndex][i-1].position.toCGPoint(), and: lastPath[pathIndex][i].position.toCGPoint())
                if distance < closestDistance {
                    closestDistance = distance
                    line = [lastPath[pathIndex][i-1], lastPath[pathIndex][i]]
                }
            }
            if closestDistance > 2 {
                banner.hide()
                return
            }
            let lineDirection = Axis.determineAxis(first: line[0], last: line[1])
            if lineDirection == locationDirection {
                banner.update(.forward)
                banner.show()
            }else if lineDirection.opposite() == locationDirection {
                banner.update(.backward)
                banner.show()
            }else{
                banner.hide()
            }
        }
    }
    
    func pointOnSegment(p: CGPoint, toLineSegment v: CGPoint, and w: CGPoint) -> CGPoint {
        let pv_dx = p.x - v.x
        let pv_dy = p.y - v.y
        let wv_dx = w.x - v.x
        let wv_dy = w.y - v.y
        
        let dot = pv_dx * wv_dx + pv_dy * wv_dy
        let len_sq = wv_dx * wv_dx + wv_dy * wv_dy
        let param = dot / len_sq
        
        var int_x, int_y: CGFloat /* intersection of normal to vw that goes through p */
        
        if param < 0 || (v.x == w.x && v.y == w.y) {
            int_x = v.x
            int_y = v.y
        } else if param > 1 {
            int_x = w.x
            int_y = w.y
        } else {
            int_x = v.x + param * wv_dx
            int_y = v.y + param * wv_dy
        }
        
        
        return CGPoint(x: int_x, y: int_y)
    }
    // Function for debugging only. Moves location marker along path
    var currentIndex = 1;
    func followRoute(){
        let locationNode = gameScene.rootNode.childNode(withName: "location", recursively: false)
        let target = lastPath[0][currentIndex]
        let panAnimation = CABasicAnimation(keyPath: "position")
        panAnimation.fromValue = NSValue(scnVector3: locationNode!.position)
        panAnimation.toValue = NSValue(scnVector3: target.position)
        panAnimation.duration = Double(0.4 * (locationNode?.position.distance(receiver: target.position))!)
        locationNode?.position = target.position
        locationNode!.addAnimation(panAnimation, forKey: nil)
        currentIndex += 1
        if lastPath[0].count == currentIndex {
            return
        }
        Timer.scheduledTimer(withTimeInterval: panAnimation.duration, repeats: false) { (timer) in
            self.followRoute()
        }
    }
    
    
    // endRoute implementation from RouteBarDelegate
    func endRoute(){
        if currentNavSession == nil {
            return
        }
        // Dismiss Route Bar
        if UIDevice.isIPad() {
            leftAnchor.constant = 20
        }else{
            heightAnchor?.constant = 200
            bottomConstant = 200
            bottomAnchor?.constant = 25
        }
        routeBottomAnchor.constant = UIDevice.isIPad() ? 100 : 150
        UIView.animate(withDuration: 0.5) {
            self.gameView.layoutIfNeeded()
        }
        //Remove All highlights from map
        removeHighlights()
        // Remove Path from map
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
        if UIDevice.isIPad() {
            resizeOverlay(.Large)
        }
        currentNavSession = nil
        banner.hide()
    }
    // Called When floor is changed. If path extends to multiple floors will display the correct path based on floor
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
    // Creates line/path on the screen from the node path given from Pathfinder
    func drawPath(_ path:[Node], radius:CGFloat, color:UIColor) -> [SCNNode]{
        var nodesAdded:[SCNNode] = []
        var prev:Node? = nil
        for n in path {
            // Create Spheres at each Node in order to give illusion of round corners
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
            // buildLineInTwoPointsWithROtation is an Extension of SCNNode. Implemented in Extensions.swift file
            let lineNode = SCNNode().buildLineInTwoPointsWithRotation(from: (prev?.position)!, to: n.position, radius: radius, color: color)
            gameScene.rootNode.addChildNode(lineNode)
            nodesAdded.append(lineNode)
            prev = n
        }
        return nodesAdded
    }
    // Applies highlight animation to a structure
    func highlight(room:Structure){
        let mat = SCNMaterial()
        mat.diffuse.contents = room.node.geometry?.firstMaterial?.diffuse.contents as! UIColor
        mat.emission.contents = UIColor.cyan
        //allow structure to extrude a bit in order to remove rendering problems on teo diffrent materials at same location
        room.node.scale.y += 0.2
        room.node.geometry?.materials[0] = mat
        // Keep track of highlighted rooms
        highlightedRooms.append(room)
        // Add pulsing animation
        let highlighAnim = CABasicAnimation(keyPath: "geometry.firstMaterial.emission.contents")
        highlighAnim.fromValue = UIColor.cyan
        highlighAnim.toValue = UIColor.clear
        highlighAnim.duration = 1
        highlighAnim.repeatCount = .infinity
        highlighAnim.autoreverses = true
        room.node.addAnimation(highlighAnim, forKey: "glow")
    }
    
    func removeHighlights(){
        // REmove all highlights from highlighted rooms
        for s in highlightedRooms{
            s.node.removeAnimation(forKey: "glow")
            s.node.geometry?.firstMaterial?.emission.contents = UIColor.clear
            s.node.scale.y -= 0.2
        }
        highlightedRooms = []
    }
    // creates label above strucure in order to symbolize room names
    func displayLabels(){
        var allLocations:[String:LabelLocation] = [:]
        for room in Global.rooms {
            // skips bathrooms since there are special symbols for bathrooms
            if room == "Bathroom" {
                continue
            }
            // Search for structure is implementd in Extensions.swift
            if let s = Global.structures.searchForStructure(room) {
                //Creates Lavel location from structure and name
                let labelLocation = LabelLocation(rooms: s.name, isStructure: true, structure: s, node: nil)
                
                if !allLocations.values.contains(labelLocation) {
                    allLocations[room] = labelLocation
                }
                else{
                    print("Duplicate(Structure) \(s.name)")
                }
                
                
            }else if let n = Global.nodes.searchForByRoom(room){
                //search for by foom is imolemented in Extensions.swift
                // THis fcreates labels from rooms thate dont have structures
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
        // Make ure there is no duplicate labels
        var labels:[[SCNNode]] = [[], []]
        for location in allLocations.values {
            var room = location.rooms[0]
            for r in location.rooms {
                if r.count > room.count {
                    room = r
                }
                if r == "Auditorium" {
                    room = r
                    break
                }
            }
            // Create Label
            let text = SCNText(string: room, extrusionDepth: 0)
            text.font = UIFont.boldSystemFont(ofSize: 0.25)
            text.firstMaterial?.diffuse.contents = UIColor.black
            
            // Allow bilboarding so it always faces camera
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
    func distanceFromPoint(p: CGPoint, toLineSegment v: CGPoint, and w: CGPoint) -> Float {
        let pv_dx = p.x - v.x
        let pv_dy = p.y - v.y
        let wv_dx = w.x - v.x
        let wv_dy = w.y - v.y
        
        let dot = pv_dx * wv_dx + pv_dy * wv_dy
        let len_sq = wv_dx * wv_dx + wv_dy * wv_dy
        let param = dot / len_sq
        
        var int_x, int_y: CGFloat /* intersection of normal to vw that goes through p */
        
        if param < 0 || (v.x == w.x && v.y == w.y) {
            int_x = v.x
            int_y = v.y
        } else if param > 1 {
            int_x = w.x
            int_y = w.y
        } else {
            int_x = v.x + param * wv_dx
            int_y = v.y + param * wv_dy
        }
        
        /* Components of normal */
        let dx = p.x - int_x
        let dy = p.y - int_y
        
        return Float(sqrt(dx * dx + dy * dy))
    }
    // openSchedule Implementation of OptionsDelegate
    func openSchedule() {
        let cont = UINavigationController(rootViewController: ScheduleController())
        cont.modalPresentationStyle = .formSheet
        present(cont, animated: true, completion: nil)
    }
    // openStaffFinder Implementation of OptionsDelegate
    func openStaffFinder() {
        let cont = UINavigationController(rootViewController: StaffSearchController())
        cont.modalPresentationStyle = .formSheet
        present(cont, animated: true, completion: nil)
    }
    //openSettings Implementation of OptionsDelegate
    func openSettings() {
        let cont = UINavigationController(rootViewController: SettingsController())
        cont.modalPresentationStyle = .formSheet
        present(cont, animated: true, completion: nil)
    }
    //Called When Notification is recieved
    @objc
    func updateLabelDisplay() {
        var shouldDisplay:Bool = UserDefaults.standard.bool(forKey: "displayRoomLabels")
        if UserDefaults.standard.object(forKey: "displayRoomLabels") == nil {
            shouldDisplay = true
        }
        for floor in roomLabels {
            for label in floor {
                label.geometry?.firstMaterial?.diffuse.contents = shouldDisplay ? UIColor.black : UIColor.clear
            }
        }
    }
    @objc
    func updateLocationType(){
//        print("CHANGING LOCATION TYPE")
        let type = UserDefaults.standard.integer(forKey: "location")
        print(type)
        locationType = type
    }
    @objc
    func dismissAllControllers(){
        var topController = presentedViewController
        while let c = topController?.presentingViewController{
            topController = c
        }
        topController?.dismiss(animated: true, completion: nil)
    }
    
    func getOrientation() -> CLDeviceOrientation{
        if UIDevice.current.orientation == .landscapeLeft {
            return .landscapeLeft
        }else if UIDevice.current.orientation == .landscapeRight {
            return .landscapeRight
        }else if UIDevice.current.orientation == .portrait {
            return .portrait
        }else if UIDevice.current.orientation == .faceUp {
            return .faceUp
        }
        return .landscapeLeft
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
        var postition: SCNVector3!
        if isStructure {
            postition = (structure?.node.getPositionFromGeometry())!
        }else{
            postition = (node?.position)!
        }
        if rooms.contains("Special Ed Office") {
            postition.z -= 0.75
        }else if rooms.contains("A176") {
            postition.x -= 0.2
        }else if rooms.contains("A174") {
            postition.x -= 0.25
        }else if rooms.contains("A175") {
            postition.x -= 0.15
        }else if rooms.contains("A173") {
            postition.x += 0.15
        }else if rooms.contains("Orchestra Room") {
            postition.z -= 0.5
        }else if rooms.contains("A170") {
            postition.z += 0.15
        }else if rooms.contains("162") {
            postition.x += 0.15
            postition.z -= 0.15
        }else if rooms.contains("167") {
            postition.x -= 0.15
        }else if rooms.contains("166") {
            postition.z += 0.15
        }else if rooms.contains("165") {
            postition.z -= 0.15
            postition.x += 0.1
        }else if rooms.contains("164") {
            postition.z += 0.15
        }else if rooms.contains("Music Office") {
            postition.x += 0.3
        }else if rooms.contains("Auditorium") {
            postition.z += 3.5
            postition.x -= 1
        }else if rooms.contains("Gym") {
            postition.x += 1.5
            postition.z -= 2
        }
        return postition
    }
    func getFloor() -> Int {
        if isStructure {
            return (structure?.floor)!
        }else{
            return (node?.floor)!
        }
    }
}
struct Point:Hashable {
    let x:CGFloat
    let y:CGFloat
    func cgpoint() -> CGPoint{
        return CGPoint(x: x, y: y)
    }
}
struct MacLocation:Codable{
    let name:String
    var x:Double
    var y:Double
    let floor:Int
}
enum Axis {
    case Horizontal
    case Vertical
    case Up
    case Down
    case Right
    case Left
    static func determineAxis(first: Node, last:Node) -> Axis{
        if abs(first.position.x - last.position.x) > abs(first.position.y - last.position.y) {
            //Left Or Right
            if last.position.x < first.position.x {
                return.Left
            }else{
                return .Right
            }
        }else{
            // UP Or Down
            if last.position.z < first.position.z {
                return .Up
            }else{
                return .Down
            }
        }
    }
    static func determineAxis(angle:Float) -> Axis {
        if angle < 45 || angle > 315 {
            return .Up
        }else if angle >= 45 && angle <= 135 {
            return .Left
        }else if angle > 135 && angle <= 225 {
            return .Down
        }else{
            return .Right
        }
    }
    func opposite() -> Axis{
        switch self {
        case .Up:
            return .Down
        case .Left:
            return .Right
        case .Right:
            return .Left
        case .Down:
            return .Up
        case .Vertical:
            return .Horizontal
        case .Horizontal:
            return .Vertical
        }
    }
}
