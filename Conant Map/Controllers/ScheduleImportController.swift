//
//  ScheduleImportController.swift
//  Conant Map
//
//  Created by Johnny Waity on 9/29/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class ScheduleImportController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let fields:[String] = ["First Name", "Last Name", "School ID", "Birthday"]
    
    var textFields:[UITextField] = []
    var datePicker:UIDatePicker!
    var dateLabel:UILabel!
    
    var tableViewHeightConstraint:NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        let titleLabel = UILabel()
        titleLabel.text = "Import Schedule"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 40)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 8
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        view.addSubview(tableView)
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 55 * 4)
        tableViewHeightConstraint.isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive=true
        
        let importButton = UIButton(type: .system)
        importButton.translatesAutoresizingMaskIntoConstraints = false
        importButton.setTitle("Import Schedule", for: .normal)
        importButton.setTitleColor(UIColor.white, for: .normal)
        importButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        importButton.backgroundColor = UIView().tintColor
        importButton.layer.cornerRadius = 8
        view.addSubview(importButton)
        importButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        importButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        importButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        importButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        importButton.addTarget(self, action: #selector(importSchedule), for: .touchUpInside)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 3 {
            let cell = TextEnterCell()
            textFields.append(cell.setup(title: fields[indexPath.row], numericOnly: indexPath.row == 2))
            return cell
        }
        let cell = DateEnterCell()
        datePicker = cell.setup(title: fields[indexPath.row])
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        dateLabel = cell.dateLabel
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let rowSelected = tableView.indexPathForSelectedRow {
            if rowSelected.row == 3 && indexPath.row == 3 {
                tableViewHeightConstraint.constant = (4 * 55) + 216
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                return 216 + 55
            }
            
        }
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row != 3){
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc
    func datePickerChanged(_ sender:UIDatePicker){
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .none
        
        let dateValue = dateformatter.string(from: sender.date)
        
        dateLabel.text = dateValue
    }
    
    @objc
    func importSchedule(){
        let firstName = textFields[0].text!
        let lastName = textFields[1].text!
        let id = textFields[2].text!
        let birthday = datePicker.date
        
        
        
        
        let alert = UIAlertController(title: "Importing Scedule", message: nil, preferredStyle: .alert)
        
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.startAnimating();
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        alert.view.addSubview(loadingIndicator)
        loadingIndicator.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: 10).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 100).isActive = true
        alert.view.addConstraint(alert.view.heightAnchor.constraint(equalToConstant: 150))
        
        present(alert, animated: true, completion: nil)
        
        
        
        let infiniteCampus = InfinteCampusController(firstName: firstName, lastName: lastName, birthday: birthday, id: id) { (result, error) in
            if let res = result {
               print(res)
                alert.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }else if let err = error {
                alert.dismiss(animated: true, completion: {
                    let errAlert = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "Ok", style: .default)
                    errAlert.addAction(action1)
                    self.present(errAlert, animated: true, completion: nil)
                })
            }
            
        }
        view.addSubview(infiniteCampus.view)
        addChildViewController(infiniteCampus)
    }
    

}
