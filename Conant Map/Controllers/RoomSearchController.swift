//
//  RoomSearchController.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/9/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class RoomSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    var pageCont:NavigationPageViewController? = nil
    
    var rooms:[String] = []
    var displayedRooms:[String] = []
    
    let table:UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    let searchCont = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupView()
    }
    
    func setPageContoller(cont:NavigationPageViewController) {
        pageCont = cont
    }

    func setupView(){
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonClicked))
        
        searchCont.obscuresBackgroundDuringPresentation = false
        searchCont.hidesNavigationBarDuringPresentation = false
        
        searchCont.searchBar.delegate = self
        navigationItem.searchController = searchCont
        let coverView:UIView = {
            let v = UIView()
            v.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()
        
        view.addSubview(coverView)
        coverView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coverView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        coverView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        coverView.heightAnchor.constraint(equalToConstant: UIApplication.shared.statusBarFrame.height).isActive = true
        
        
        navigationItem.title = "Select Room"
        
//        let search = UISearchBar()
//        search.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(search)
//        search.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.frame.height)!).isActive = true
//        search.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        search.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        search.delegate = self
        //search.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        
        
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        table.heightAnchor.constraint(equalToConstant: view.frame.height - (navigationController?.navigationBar.frame.height)! * 2).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        table.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
    }
    @objc
    func cancelButtonClicked(){
        pageCont?.changePage(page: 0, direction: .reverse, room: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = displayedRooms[indexPath.item]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pageCont?.changePage(page: 0, direction: .reverse, room: tableView.cellForRow(at: indexPath)?.textLabel?.text)
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        displayedRooms = rooms.sortByComparison(searchBar.text!)
        table.reloadData()
        searchBar.endEditing(true)
        searchCont.isActive = false
    }
    
    

    

}


