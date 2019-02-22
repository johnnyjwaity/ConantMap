//
//  MacAddressParser.swift
//  Conant Map
//
//  Created by Johnny Waity on 1/30/19.
//  Copyright © 2019 Johnny Waity. All rights reserved.
//

import Foundation

class MacAddressParser{
    static func parse() -> [MacAddress]{
        var addresses:[MacAddress] = []
        var lines:[String] = []
        do{
            //Get File Path
            let path = Bundle.main.path(forResource: "Mac-Addresses", ofType: "csv")
            //String from File
            let rawString = try String(contentsOfFile: path!)
            //Seperate lines fron String
            lines = rawString.components(separatedBy: .newlines)
        }catch{
            print(error)
        }
        lines.remove(at: 0)
        for line in lines {
            if !line.contains(",") {
                continue
            }
            let components = line.components(separatedBy: ",")
            let address = MacAddress(name: components[0], address: components[1])
            addresses.append(address)
        }
        return addresses
    }
}
