//
//  ColorGenerator.swift
//  ColorFinder
//
//  Created by NoboPay on 9/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class ColorGenerator: NSObject {

    static func ColorHomo(red:UInt8, green:UInt8, blue:UInt8, hueAngle:Float)->CRGB{
        let color_data = UnsafeMutablePointer<CRGB>.allocate(capacity: 1)
        color_data.pointee.r = red
        color_data.pointee.g = green
        color_data.pointee.b = blue
        let data = TransformH(color_data, hueAngle)
//        let _color = UIColor.init(red: CGFloat(data.r)/255.0, green: CGFloat(data.g)/255.0, blue: CGFloat(data.b)/255.0, alpha: 1)
        color_data.deallocate()
        return data
    }
    
    static func ColorInvert(red:UInt8, green:UInt8, blue:UInt8, hueAngle:Float )->CRGB{
        let color_data = UnsafeMutablePointer<CRGB>.allocate(capacity: 1)
        color_data.pointee.r = 255 - red
        color_data.pointee.g = 255 - green
        color_data.pointee.b = 255 - blue
        let data = TransformH(color_data, hueAngle)
        return data
    }
    
    static func ColorShade(red:UInt8, green:UInt8, blue:UInt8, blackPercent:UInt8 )->CRGB{
//        let value = UInt8(blackPercent > 100 ? 100 : blackPercent)
  
        let cr:UInt8 = UInt8(Float(Int(red) * Int(blackPercent)) / 100.0) // CGFloat(red) / 255.0 * percent
        let cg:UInt8 = UInt8(Float(Int(green) * Int(blackPercent)) / 100.0) //CGFloat(green) / 255.0 * percent
        let cb:UInt8 = UInt8(Float(Int(blue) * Int(blackPercent)) / 100.0) // CGFloat(blue) / 255.0 * percent
        var color:CRGB = CRGB()
        color.r = cr
        color.b = cb
        color.g = cg
        return color
    }
    
}
