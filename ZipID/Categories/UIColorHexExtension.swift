//
//  UIColorHexExtension.swift
//  ZipID
//
//  Created by Damien Hill on 19/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1)
    }
    
    convenience init(hex: Int, alpha: CGFloat) {
        let redInt = (hex >> 16) & 0xff
        let greenInt = (hex >> 8) & 0xff
        let blueInt = hex & 0xff
        
        let red = CGFloat(redInt) / 255.0
        let green = CGFloat(greenInt) / 255.0
        let blue = CGFloat(blueInt) / 255.0
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}