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
    
    var delegate:ScheduleImportDelegate!
    
    var toolbar:UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Import Schedule"
        // Do any additional setup after loading the view.
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        self.view.addGestureRecognizer(tapGesture)
        
        let titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
//        let cancelButton = UIButton(type: .system)
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        cancelButton.setTitle("Cancel", for: .normal)
//        cancelButton.addTarget(self, action: #selector(exit), for: .touchUpInside)
//        view.addSubview(cancelButton)
//        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
//        cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
//        cancelButton.rightAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        
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
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30).isActive = true
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
        
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    @objc
    func dismissKeyboard (){
        self.view.endEditing(true)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 3 {
            let cell = TextEnterCell()
            let field = cell.setup(title: fields[indexPath.row], numericOnly: indexPath.row == 2)
            field.inputAccessoryView = toolbar
            textFields.append(field)
            
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
                UIView.animate(withDuration: 0.15) {
                    self.view.layoutIfNeeded()
                }
                return 216 + 55
            }
            
        }
        return 55
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Index \(indexPath.row)")
        if(indexPath.row != 3){
            tableView.deselectRow(at: indexPath, animated: true)
            textFields[indexPath.row].becomeFirstResponder()
            return
        }
        print("BDay")
        dismissKeyboard()
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
        
        
        if firstName == "" || lastName == "" || id == "" {
            return
        }
        
        
        let alert = UIAlertController(title: "Importing Schedule", message: nil, preferredStyle: .alert)
        
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
//        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .gray
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
        
        Network.getSchedule(firstName: firstName, lastName: lastName, birthday: birthday, id: id) { (schedule, error) in
            DispatchQueue.main.async {
                if let e = error {
                    alert.dismiss(animated: true, completion: {
                        let errAlert = UIAlertController(title: "Error", message: e, preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ok", style: .default)
                        errAlert.addAction(action1)
                        self.present(errAlert, animated: true, completion: nil)
                    })
                }else if let s = schedule {
                    alert.dismiss(animated: true, completion: {
                        let schedule = Schedule(s)
                        schedule.save()
                        self.delegate.displayScheudle(schedule)
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
            
        }
        
//        let infiniteCampus = InfinteCampusController(firstName: firstName, lastName: lastName, birthday: birthday, id: id) { (result, error) in
//            if let res = result {
//               print(res)
//                alert.dismiss(animated: true, completion: {
//                    let schedule = Schedule(res)
//                    schedule.save()
//                    self.delegate.displayScheudle(schedule)
////                    self.dismiss(animated: true, completion: nil)
//                    self.navigationController?.popViewController(animated: true)
//                })
//            }else if let err = error {
//                alert.dismiss(animated: true, completion: {
//                    let errAlert = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
//                    let action1 = UIAlertAction(title: "Ok", style: .default)
//                    errAlert.addAction(action1)
//                    self.present(errAlert, animated: true, completion: nil)
//                })
//            }
//
//        }
//        view.addSubview(infiniteCampus.view)
//        addChild(infiniteCampus)
    }
    

}
