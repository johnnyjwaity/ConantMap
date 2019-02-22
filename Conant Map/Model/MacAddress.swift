//
//  MacAddress.swift
//  Conant Map
//
//  Created by Johnny Waity on 1/30/19.
//  Copyright © 2019 Johnny Waity. All rights reserved.
//

import Foundation
struct MacAddress:Codable{
    let name:String
    let address:String
    
    func convert() -> String {
//        let address = "186472c77dcc"
        
        let bssidPerEthernet = 18
        
        let f1 = String(Int(address.suffix(6), radix: 16)!, radix: 2) + "0000" //binary
//        print(f1)
        //print(String(f1.prefix(8)))
        //print(xor(bin1: String(f1.prefix(8)), bin2: "00001000"))
        let f2 = xor(bin1: String(f1.prefix(8)), bin2: "00001000")
//        print(f2)
        
        
//        print(f2.suffix(4))
//        print(f1.suffix(f1.count - 8))
        
        let out = Int(String(f2.suffix(4)) + String(f1.suffix(f1.count - 8)), radix: 2)!
//        print(out)
        
        let r1 = String(out + bssidPerEthernet, radix: 16)
//        print(r1)
        let newAddress = String(address.prefix(6)) + r1
//        print(newAddress)
        return newAddress
    }
    
    func xor(bin1:String, bin2:String) -> String{
        let bin1Digits:[Int] = bin1.compactMap{Int(String($0))}
        let bin2Digits:[Int] = bin2.compactMap{Int(String($0))}
        var retStr = ""
        for i in 0 ..< bin1Digits.count {
            if bin2Digits[i] == 1 {
                retStr += "\(bin1Digits[i] == 0 ? 1 : 0)"
            }else{
                retStr += "\(bin1Digits[i])"
            }
        }
        return retStr
    }
    
    static func readable(_ address:String) -> String{
        var a = address
        for i in 0...9 {
            if i % 2 == 0 {
                a.insert(":", at: a.index(a.startIndex, offsetBy: 10 - i))
            }
        }
        return a
    }
}
//186472f7dcd2
//C-R-221.d211.org,186472c77dcc
//C-R-203.d211.org,186472c77dc8
