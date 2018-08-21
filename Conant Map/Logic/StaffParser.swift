//
//  StaffParser.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

class StaffParser{
    static func parseStructures(_ file:String){
        //Prepare Array For Staff
        var staff:[Staff] = []
        var classes:[Class] = []
        //Prepare Array For Lines
        var lines:[String] = []
        do{
            //Get File Path
            let path = Bundle.main.path(forResource: file, ofType: "dat")
            //String from File
            let rawString = try String(contentsOfFile: path!)
            //Seperate lines fron String
            lines = rawString.components(separatedBy: .newlines)
        }catch{
            print(error)
        }
        //Iterate Through Each Line Of File
        for line in lines {
            //If there is no information on current line
            if Array(line).count <= 0 {
                continue
            }
            //Header determines what property of the node is currently being read
            let header = Array(line)[0]
            /*
             Header Types
             
             */
            
            
        }
    }
}
