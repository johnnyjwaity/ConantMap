//
//  StairParser.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/26/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

class StairParser{
    static func parseStairs(_ file:String) -> [Stair]{
        //Prepare Array For Stairs
        var stairs:[Stair] = []
        //Prepare Array For Lines
        var lines:[String] = []
        if file == "fallback" {
            do{
                //Get File Path
                let path = Bundle.main.path(forResource: "stairs", ofType: "dat")
                //String from File
                let rawString = try String(contentsOfFile: path!)
                //Seperate lines fron String
                lines = rawString.components(separatedBy: .newlines)
            }catch{
                print(error)
            }
        }else {
            lines = file.components(separatedBy: .newlines)
        }
        
        var currentStair:Stair? = nil
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
             % name of the Stair
             $ id of stair
             * is elevator
             ^ name of node that allows entry to stair
             */
            
            //Phrase is the property being read
            let phrase = String(line.suffix(line.count-1))
            switch header {
            case "%":
                if let s = currentStair {
                    stairs.append(s)
                }
                currentStair = Stair(phrase)
                break;
            case "$":
                currentStair?.id = Int(phrase)!
                break
            case "*":
                currentStair?.isElevator = ((phrase == "true") ? true : false)
                break
            case "^":
                currentStair?.entryStr = phrase
                break
            default:
                break
            }
        }
        stairs.append(currentStair!)
        return stairs
    }
}
