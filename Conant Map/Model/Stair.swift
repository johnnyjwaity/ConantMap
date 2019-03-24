//
//  Stair.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/26/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import SceneKit

class Stair{
    let name:String
    var id:Int = 0
    var isElevator:Bool = false
    var entryStr:String = ""
    var postion:SCNVector3!
    var entryNode:Node? = nil
    var floor:Int = 0
    var complementary:Stair!
    
    init(_ name:String){
        self.name = name
    }
}
