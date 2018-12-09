//
//  Startup.swift
//  Conant Map
//
//  Created by Johnny Waity on 12/1/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import UIKit

class Startup {
    static func update(){
        
        let url = URL(string: "http://mc.johnnywaity.com:3000/version-list")
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            do{
                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
                    checkVersions(versions: json as! [String:Int])
                }
            }catch let err {
                print(err.localizedDescription)
            }
        }
        task.resume()
        
        
    }
    
    static func checkVersions(versions:[String: Int]){
        var myVersions = ["staff": 0, "stairs": 0, "nodes": 0, "colors": 0]
        if let v = UserDefaults.standard.dictionary(forKey: "versions") as? [String: Int] {
            myVersions = v
        }else {
            UserDefaults.standard.set(myVersions, forKey: "versions")
        }
        for key in versions.keys {
            if myVersions[key]! < versions[key]! {
                print("Need To Update \(key)")
                fetchFile(key)
            }
        }
        
    }
    
    static func fetchFile(_ name:String){
        let url = URL(string: "http://mc.johnnywaity.com:3000/file?name=\(name)")
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            let dat = String(data: data!, encoding: String.Encoding.ascii)
            
            UserDefaults.standard.set(dat, forKey: name)
            
        }
        task.resume()
    }
    
}
