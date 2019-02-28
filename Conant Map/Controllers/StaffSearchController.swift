//
//  StaffSearchController.swift
//  Conant Map
//
//  Created by Johnny Waity on 12/28/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class StaffSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    

    let tableView = UITableView()
    var selectedCell:IndexPath? = nil
    var staff:[Staff] = []
    var sortedStaff:[Staff] = []
    
    var filterButton:UIButton!
    
    static var sharedInstance:StaffSearchController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Staff Finder"
        StaffSearchController.sharedInstance = self
        var departments:[String] = []
        for s in Global.staff {
            if !departments.contains(s.department) {
                departments.append(s.department)
            }
        }
        print(departments)
        staff = Global.staff
        sortedStaff = staff
        setupView()
    }
    
    func setupView(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))
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
        navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        navBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search For Teacher"
        navBar.addSubview(searchBar)
        searchBar.leftAnchor.constraint(equalTo: navBar.leftAnchor, constant: 3.5).isActive = true
        searchBar.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalTo: navBar.widthAnchor, constant: -52).isActive = true
        searchBar.heightAnchor.constraint(equalTo: navBar.heightAnchor, constant: -10).isActive = true
        searchBar.delegate = self
        
        filterButton = UIButton(type: .system)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        let img = #imageLiteral(resourceName: "filter").withRenderingMode(.alwaysTemplate)
        filterButton.setImage(img, for: .normal)
        navBar.addSubview(filterButton)
        filterButton.leftAnchor.constraint(equalTo: searchBar.rightAnchor).isActive = true
        filterButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        filterButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        filterButton.addTarget(self, action: #selector(displayFilter), for: .touchUpInside)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(StaffCell.self, forCellReuseIdentifier: "staff")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sortedStaff.count > 0 {
            return 75
        }else{
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedStaff.count > 0{
            return sortedStaff.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sortedStaff.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "staff") as! StaffCell
            cell.changeInfo(sortedStaff[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.textLabel?.text = "No Results Found :("
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterArray(searched: searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if sortedStaff.count == 0 {
            return
        }
        let viewCont:UIViewController = StaffInfoController(name: sortedStaff[indexPath.row].name)
        let placeHolder = UIViewController()
        placeHolder.title = "Staff Finder"
        let search = SearchNavigationController(rootViewController: placeHolder)
        search.modalPresentationStyle = .currentContext
        search.pushViewController(viewCont, animated: false)
        present(search, animated: true, completion: nil)
    }
    
    
    func filterArray(searched:String){
        var contains:[Staff] = []
        var discard:[Staff] = []
        let search = searched.lowercased()
        for staffI in staff {
            let staffOG = staffI
            let staff = staffI.name.lowercased()
            if staff.contains(search){
                contains.append(staffOG)
            }
            else{
                discard.append(staffOG)
            }
        }
        sortedStaff = contains
//        sortedStaff.append(contentsOf: discard)
        tableView.reloadData()
        if sortedStaff.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
    }
    
    func sortByFirstName(){
        sortedStaff = staff.sorted {$0.name < $1.name}
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    func sortByLastName(){
        sortedStaff = staff.sorted {$0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]}
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    func sortByDepartment(){
        sortedStaff = []
        var staffDepartments:[String: [Staff]] = [:]
        for s in staff {
            var department = ""
            if s.department.contains("English") {
                department = "English"
            }else{
                department = s.department
            }
            
            if !staffDepartments.keys.contains(department) {
                staffDepartments[department] = []
            }
            
            staffDepartments[department]?.append(s)
        }
        let departments = Array(staffDepartments.keys).sorted {$0 < $1}
        for d in departments {
            let ss = (staffDepartments[d]!).sorted {$0.name < $1.name}
            for s in ss {
                sortedStaff.append(s)
            }
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    @objc
    func displayFilter(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let name = UIAlertAction(title: "By First Name", style: .default) { (action) in
            self.sortByFirstName()
        }
        alertController.addAction(name)
        let lastName = UIAlertAction(title: "By Last Name", style: .default) { (action) in
            self.sortByLastName()
        }
        alertController.addAction(lastName)
        let dep = UIAlertAction(title: " By Department", style: .default) { (action) in
            self.sortByDepartment()
        }
        alertController.addAction(dep)
        alertController.modalPresentationStyle = .popover
        let popover = alertController.popoverPresentationController
        popover?.sourceView = filterButton
        popover?.sourceRect = filterButton.bounds
        popover?.permittedArrowDirections = .any
        present(alertController, animated: true, completion: nil)
    }
    
    @objc
    func close(){
        StaffSearchController.sharedInstance = nil
        dismiss(animated: true, completion: nil)
    }

}
