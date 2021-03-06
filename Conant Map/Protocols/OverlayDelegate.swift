//
//  OverlayDelegate.swift
//  Conant Map
//
//  Created by Johnny Waity on 7/3/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation

protocol OverlayDelegate {
    func resizeOverlay(_ size:OverlaySize)
    func startNavigation(_ session:NavigationSession)
}

enum OverlaySize{
    case Large
    case xMedium
    case Medium
    case Small
}
