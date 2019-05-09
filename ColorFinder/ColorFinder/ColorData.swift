//
//  ColorData.swift
//  ColorFinder
//
//  Created by NoboPay on 9/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class Color{
    
    let color_id:String
    let red:Int
    let green:Int
    let blue:Int
    let alpha:Int
    let intRGB:UInt32
    
    
    init(withJson jsonData:[String:JSON]) {
        self.color_id = jsonData["id"]?.stringValue ?? UUID().uuidString
        self.red = jsonData["red"]?.intValue ?? 255
        self.green = jsonData["green"]?.intValue ?? 255
        self.blue = jsonData["blue"]?.intValue ?? 255
        self.alpha = jsonData["alpha"]?.intValue ?? 255
        self.intRGB = UInt32(jsonData["rgb"]?.intValue ?? 0xFFFFFF)
    }
    
    init(r:Int,g:Int, b:Int, a:Int = 255) {
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
        self.intRGB =  UInt32(65536 * r + 256 * g + b)
        self.color_id = Color.getColorID()
    }
    
    static func getColorID()->String {
        let uid = UUID().uuidString
        let index = uid.index(uid.startIndex, offsetBy: 10)
        var id = InterfaceHelper.randomStr(5)
        let value = String(uid[..<index])
        id.append(value)
        return id
    }
    
    init(hex:Int, a:Int = 255){
        let rgbValue = hex
        self.red = (rgbValue & 0xFF0000) >> 16
        self.green = (rgbValue & 0x00FF00) >> 8
        self.blue = rgbValue & 0x0000FF
        self.intRGB =  UInt32(rgbValue)
        self.alpha = a
        self.color_id = Color.getColorID()
    }
    
    func toColor()->UIColor{
        return UIColor.init(red: CGFloat(self.red)/255.0,
                            green: CGFloat(self.green)/255.0,
                            blue: CGFloat(self.blue)/255.0,
                            alpha: CGFloat(self.alpha)/255.0)
    }
    
    func toJson() -> String{
        return "{\"id\" : \"\(self.color_id)\", \"red\" : \(self.red), \"green\" : \(self.green), \"blue\" : \(self.blue), \"alpha\" : \(self.alpha), \"rgb\" : \(self.intRGB)}"
    }
}

class ColorData: NSObject {
    
    
    static let shared = ColorData()
    var colorDataArray:[Color] = []
    let saver = ColorSaver.shared
    override init() {
        super.init()
    }
    
    func add(Color color:Color)->Bool {
        let saved = self.saver.save(Color: color)
        colorDataArray.append(color)
        return saved
    }
    
    func delete(Color color:Color)->Bool{
        self.colorDataArray = self.colorDataArray.filter({ (_color) -> Bool in
            return !_color.color_id.elementsEqual(color.color_id)
        })
        let deleted = self.saver.delete(Color: color)
        return deleted
    }
}
