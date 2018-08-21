//
//  Structure.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/26/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Structure {
    let name:[String]
    var color:UIColor = UIColor.white
    var node:SCNNode!
    var floor:Int!
    
    init(_ name:[String]) {
        self.name = name
    }
}
