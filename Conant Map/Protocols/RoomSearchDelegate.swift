//
//  RoomSearchDelegate.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/30/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

protocol RoomSearchDelegate {
    func roomSelected(name:String, pos:NavPosition)
    func showRoomInfo(controller:RoomSearchController, room:String)
}

enum NavPosition {
    case To
    case From
    case Undetermined
    
    func toNavPosition(direction:String) -> NavPosition {
        if direction.lowercased().contains("from") {
            return NavPosition.From
        }
        return NavPosition.To
    }
}
