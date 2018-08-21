//
//  RoomSearchController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit
import SceneKit

class RoomSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let tableView = UITableView()
    var selectedCell:IndexPath? = nil
    var rooms:[String] = []
    var sortedRooms:[String] = []

    var delegate:RoomSearchDelegate!
    
    var searchingFor:NavPosition
    
    init() {
        searchingFor = .Undetermined
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ searchingFor:NavPosition) {
        self.searchingFor = searchingFor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rooms = Global.rooms
        sortedRooms = rooms
        setupView()
    }
    
    func setupView(){
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        let navBar:UIView = {
            let v = UIView()
            v.layer.cornerRadius = 8
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = UIColor.white
            
            let l = UIView()
            l.backgroundColor = UIColor.lightGray
            l.translatesAutoresizingMaskIntoConstraints = false
            v.addSubview(l)
            l.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
            l.leftAnchor.constraint(equalTo: v.leftAnchor).isActive = true
            l.rightAnchor.constraint(equalTo: v.rightAnchor).isActive = true
            l.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            return v
        }()
        view.addSubview(navBar)
        navBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search For Room"
        navBar.addSubview(searchBar)
        searchBar.centerXAnchor.constraint(equalTo: navBar.centerXAnchor).isActive = true
        searchBar.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalTo: navBar.widthAnchor, constant: -7).isActive = true
        searchBar.heightAnchor.constraint(equalTo: navBar.heightAnchor, constant: -10).isActive = true
        searchBar.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(RoomCell.self, forCellReuseIdentifier: "room")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = selectedCell {
            if indexPath.item == cell.item {
                return 125
            }
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var pcell = tableView.dequeueReusableCell(withIdentifier: "room")
        if(pcell == nil){
            pcell = RoomCell()
        }
        let cell = pcell as! RoomCell
        cell.setUpCell(room: sortedRooms[indexPath.item])
        cell.toButton.tag = indexPath.row
        cell.toButton.addTarget(self, action: #selector(navButtonClicked), for: .touchUpInside)
        
        cell.fromButton.tag = indexPath.row
        cell.fromButton.addTarget(self, action: #selector(navButtonClicked), for: .touchUpInside)
        
        cell.infoButton.addTarget(self, action: #selector(roomInfoClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterArray(searched: searchBar.text!)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let i = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: i, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RoomCell
        sendHighlightRequest(room: cell.roomName)
        
        if searchingFor != .Undetermined {
            delegate.roomSelected(controller: self, name: cell.roomName, pos: searchingFor)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if let cell = selectedCell {
            let rCell = tableView.cellForRow(at: cell) as! RoomCell
            rCell.deselected()
        }
        selectedCell = indexPath
        print("Selected Cell")
        cell.selected()
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func sendHighlightRequest(room:String){
        if let s = Global.structures.searchForStructure(room) {
            MapViewController.main?.removeHighlights()
            MapViewController.main?.highlight(room: s)
            MapViewController.main?.floorSelect.setFloor(s.floor)
            let min:SCNVector3 = (Global.structures.searchForStructure(room)?.node.geometry?.boundingBox.min)!
            let max:SCNVector3 = (Global.structures.searchForStructure(room)?.node.geometry?.boundingBox.max)!
            let avg = min.midpoint(max)
            MapViewController.main?.camera?.panToPosition(avg, type: .Room, room: (s.floor == 2) ? s : nil, floor: s.floor)
        }
        else{
            MapViewController.main?.removeHighlights()
            MapViewController.main?.camera?.panToPosition((Global.nodes.searchForByRoom(room)?.position)!, type: .Node, room: nil, floor: (Global.nodes.searchForByRoom(room)?.floor)!)
            MapViewController.main?.floorSelect.setFloor((Global.nodes.searchForByRoom(room)?.floor)!)
        }
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let cell = selectedCell {
            let rCell = tableView.cellForRow(at: cell) as! RoomCell
            rCell.deselected()
        }
        selectedCell = nil
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func filterArray(searched:String){
        var contains:[String] = []
        var discard:[String] = []
        let search = searched.lowercased()
        for roomI in rooms {
            let roomOG = roomI
            let room = roomI.lowercased()
            if room.contains(search){
                contains.append(roomOG)
            }
            else{
                discard.append(roomOG)
            }
        }
        sortedRooms = contains
        sortedRooms.append(contentsOf: discard)
        tableView.reloadData()
    }
    
    @objc
    func navButtonClicked(sender:UIButton) {
        for child in sender.subviews {
            if let d = child as? DataHolder {
                print(d.data["room"] as! String)
                let room:String = d.data["room"] as! String
                let direction = NavPosition.To.toNavPosition(direction: (sender.titleLabel?.text)!)
                delegate.roomSelected(controller: self, name: room, pos: direction)
            }
        }
    }
    @objc
    func roomInfoClicked(sender:UIButton){
        for child in sender.subviews {
            if let d = child as? DataHolder {
                let room:String = d.data["room"] as! String
                delegate.showRoomInfo(controller: self, room: room)
            }
        }
    }

}


