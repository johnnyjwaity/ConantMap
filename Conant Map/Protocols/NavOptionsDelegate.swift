//
//  NavOptionsDelegate.swift
//  Conant Map
//
//  Created by Johnny Waity on 7/1/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

protocol NavOptionsDelegate {
    func findRoomRequested(location:NavPosition)
    func startRoute(_ session:NavigationSession)
}
