//
//  Extensions.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/5/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    func getPixelColor() -> [[UIColor]] {
        let provider = self.cgImage?.dataProvider
        let providerData = provider?.data
        let data = CFDataGetBytePtr(providerData)
        var colors:[[UIColor]] = []
        let width = 2200
        let height = 1700
        let numberOfComponents = 4
        print()
        for y in 0...Int(height-1){
            var row:[UIColor] = []
            for x in 0...Int(width-1){
                let pixelData = ((Int(width) * y) + x) * numberOfComponents
                let r = CGFloat(data![pixelData])  / 255.0
                let g = CGFloat(data![pixelData + 1]) / 255.0
                let b = CGFloat(data![pixelData + 2]) / 255.0
                let a = CGFloat(data![pixelData + 3]) / 255.0
                row.append(UIColor(red: r, green: g, blue: b, alpha: a))
            }
            colors.append(row)
        }
        return colors
    }
}

extension UIView {
    //var myConstraints:[String:NSLayoutConstraint] = [:]
}
