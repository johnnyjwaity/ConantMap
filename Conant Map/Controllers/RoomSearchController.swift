//
//  RoomSearchController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class RoomSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let tableView = UITableView()
    var selectedCell:IndexPath? = nil
    var rooms:[String] = []
    var sortedRooms:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        rooms = Global.rooms
        sortedRooms = rooms
        setupView()
    }
    
    func setupView(){
        view.translatesAutoresizingMaskIntoConstraints = false
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
                return 100
            }
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RoomCell()
        cell.setUpCell(room: sortedRooms[indexPath.item])
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterArray(searched: searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = selectedCell {
            let rCell = tableView.cellForRow(at: cell) as! RoomCell
            rCell.deselected()
        }
        selectedCell = indexPath
        print("Selected Cell")
        let cell = tableView.cellForRow(at: indexPath) as! RoomCell
        cell.selected()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func filterArray(searched:String){
        var contains:[String] = []
        var discard:[String] = []
        let search = searched.lowercased()
        for roomI in rooms {
            let room = roomI.lowercased()
            if room.contains(search){
                contains.append(room)
            }
            else{
                discard.append(room)
            }
        }
        sortedRooms = contains
        sortedRooms.append(contentsOf: discard)
        tableView.reloadData()
    }

}


