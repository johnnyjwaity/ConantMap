//
//  NodeParser.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/13/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation


class NodeParser {
    static func parse(file:String) -> [Node] {
        var nodes:[Node] = []
        var lines:[String] = []
        do{
            let path = Bundle.main.path(forResource: file, ofType: "dat")
            let rawString = try String(contentsOfFile: path!)
            lines = rawString.components(separatedBy: .newlines)
        }catch{
            print(error)
        }
        var count = 0
        var n:Node? = nil
        for line in lines {
            if Array(line).count <= 0 {
                continue
            }
            let header = Array(line)[0]
            let phrase = String(line.suffix(line.count-1))
            switch header {
            case "%":
                if n != nil{
                    nodes.append(n!)
                }
                n = Node(phrase, id: count)
                count+=1
                break;
            case "x":
                n?.x = Double(phrase)!
                break;
            case "y":
                n?.y = Double(phrase)!
                break;
            case "-":
                n?.strConnections.append(phrase)
                break;
            case "@":
                n?.rooms.append(phrase)
                break;
            default:
                break
            }
        }
        nodes.append(n!)
        
        for n in nodes {
            for s in n.strConnections {
                n.connections.append(searchForNode(name: s, nodes: nodes)!)
            }
        }
        
        
        return nodes
    }
    
    static func searchForNode(name:String, nodes:[Node]) -> Node? {
        for n in nodes {
            if n.name == name {
                return n
            }
        }
        return nil
    }
}
