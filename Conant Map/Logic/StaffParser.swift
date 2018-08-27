//
//  StaffParser.swift
//  Conant Map
//
//  Created by Johnny Waity on 8/20/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

class StaffParser{
    static func parseStaff(_ file:String){
        //Prepare Array For Staff
        var staff:[Staff] = []
        var classes:[Class] = []
        
        var currentStaff:Staff? = nil
        var currentClass:Class? = nil
        
        
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
             
             Staff:
             ! - name
             # - phone
             % - email
             ^ - department
             & - classes
             
             Class:
             ? - name
             * - location
             $ - id
             @ - period
             
             */
            let phrase = String(line.suffix(line.count-1))
            
            
            
            switch header {
            case "!":
                if let s = currentStaff {
                    staff.append(s)
                }
                currentStaff = Staff(phrase)
                break
            case "#":
                currentStaff?.phoneNum = phrase
                break
            case "%":
                currentStaff?.email = phrase
                break
            case "^":
                currentStaff?.department = phrase
                break
            case "&":
                if phrase.count > 0 {
                    currentStaff?.classIds = phrase.components(separatedBy: ",")
                }
                break
                
            case "?":
                if let c = currentClass {
                    classes.append(c)
                }
                currentClass = Class(phrase)
                break
            case "*":
                currentClass?.location = phrase
                break
            case "$":
                currentClass?.id = phrase
                break
            case "@":
                currentClass?.period = phrase
                break
                
            default:
                break
            }
        }
        staff.append(currentStaff!)
        classes.append(currentClass!)
        Global.staff = staff
        Global.classes = classes
    }
}
