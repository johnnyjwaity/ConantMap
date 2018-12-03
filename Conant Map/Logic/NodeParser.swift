//
//  NodeParser.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/13/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation


class NodeParser {
    /* Parses Node Data From File */
    static func parse(file:String) -> [Node] {
        //Prepare Array For Nodes
        var nodes:[Node] = []
        //Prepare Array For Lines in Node File
        let lines:[String] = file.components(separatedBy: .newlines)
//        do{
//            //Get File Path
//            let path = Bundle.main.path(forResource: file, ofType: "dat")
//            //String from File
//            let rawString = try String(contentsOfFile: path!)
//            //Seperate lines fron String
//            lines = rawString.components(separatedBy: .newlines)
//        }catch{
//            print(error)
//        }
        //Node Count
        var count = 0
        //Current Node being edited
        var n:Node? = nil
        //Iterate through the lines In order to construct Each Node
        for line in lines {
            //If there is no information on current line
            if Array(line).count <= 0 {
                continue
            }
            //Header determines what property of the node is currently being read
            let header = Array(line)[0]
            /*
             Header Types
             % name of the node
             - name of a node that has a connection with current node
             @ name of room this node is by
             */
            
            //Phrase is the property being read
            let phrase = String(line.suffix(line.count-1))
            
            //Changes properties based on header
            switch header {
            case "%":
                //The % Header indicates that the previous node is complete and a new ome is starting
                if n != nil{
                    //Appends completed node to array of nodes
                    nodes.append(n!)
                }
                //Constructs a new node
                n = Node(phrase, id: count)
                count+=1
                break;
            case "-":
                //Adds connection to node
                n?.strConnections.append(phrase)
                break;
            case "@":
                //Adds room to node
                n?.rooms.append(phrase)
                break;
            default:
                break
            }
        }
        //Appends the final node that was created
        nodes.append(n!)
        //Gives nodes references to the actual Node object
        for n in nodes {
            for s in n.strConnections {
                n.connections.append(searchForNode(name: s, nodes: nodes)!)
            }
        }
        
        //returns array of nodes
        return nodes
    }
    
    /* Finds node from array based on the nodes name */
    static func searchForNode(name:String, nodes:[Node]) -> Node? {
        for n in nodes {
            if n.name == name {
                return n
            }
        }
        return nil
    }
}
