//
//  RouteController.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/21/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit

class RouteController: UIViewController {
    
    let routeLabel = UILabel()
    var delegate:RouteBarDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setupView(_ session:NavigationSession){
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        
        let endRouteButton = UIButton(type: .system)
        endRouteButton.backgroundColor = UIColor.red
        endRouteButton.setTitle("End Route", for: .normal)
        endRouteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        endRouteButton.layer.cornerRadius = 8
        endRouteButton.translatesAutoresizingMaskIntoConstraints = false
        endRouteButton.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(endRouteButton)
        if UIDevice.isIPad() {
            endRouteButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
            endRouteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            endRouteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7).isActive = true
            endRouteButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        }else{
            endRouteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            endRouteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
            endRouteButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
            endRouteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        }
        endRouteButton.addTarget(self, action: #selector(endRoute), for: .touchUpInside)
        
        
        
        routeLabel.text = "\(session.startStr) -> \(session.endStr)"
        routeLabel.translatesAutoresizingMaskIntoConstraints = false
        routeLabel.adjustsFontSizeToFitWidth = true
        routeLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(routeLabel)
        routeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        if UIDevice.isIPad() {
            routeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            routeLabel.rightAnchor.constraint(equalTo: endRouteButton.leftAnchor, constant: -5).isActive = true
            routeLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        }else{
            routeLabel.textAlignment = .center
            routeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
            routeLabel.bottomAnchor.constraint(equalTo: endRouteButton.topAnchor).isActive = true
            routeLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
    }
    
    func changeRooms(_ session:NavigationSession){
        routeLabel.text = "\(session.startStr) → \(session.endStr)"
    }
    
    @objc
    func endRoute(){
        delegate.endRoute()
    }
    

}
