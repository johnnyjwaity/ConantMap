//
//  Extensions.swift
//  Conant Map
//
//  Created by Johnny Waity on 6/5/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

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

func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
    let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
    if length == 0 {
        return SCNVector3(0.0, 0.0, 0.0)
    }
    
    return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
    
}

extension SCNNode {
    
    func buildLineInTwoPointsWithRotation(from startPoint: SCNVector3,
                                          to endPoint: SCNVector3,
                                          radius: CGFloat,
                                          color: UIColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
            
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = normalizeVector(av)
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        return self
    }
}

extension Array where Iterator.Element == String {
    func sortByComparison (_ c:String) -> [String] {
        let sorted:[String] = self.filter({(room:String) -> Bool in
            return room.lowercased().contains(c.lowercased())
        })
        return sorted
    }
}
