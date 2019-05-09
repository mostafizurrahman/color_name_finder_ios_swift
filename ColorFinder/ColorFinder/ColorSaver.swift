//
//  ColorSaver.swift
//  ColorFinder
//
//  Created by NoboPay on 9/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class ColorSaver: NSObject {

    typealias IH = InterfaceHelper
    //MARK:DELETE,SAVE,UPDATE
    //in json color data
    static let shared = ColorSaver()
    let fm = FileManager.default
    var isReadData = false
    
    var jsonData:JSON?
    let colorData = ColorData.shared
    override init() {
        super.init()
        self.isReadData = self.setJSON()
    }
    
    fileprivate func setJSON()->Bool{
        let jpath = IH.DOC_PATH.appending("/color_data.json")
        if !self.fm.fileExists(atPath: jpath){
            do {
                let url = URL(fileURLWithPath: jpath)
                try "{\"color_data\" : []}".write(to: url, atomically: true, encoding: .utf8)
                return true
            } catch {
                print(error)
            }
        } else {
            return self.read(ColorsPath:jpath)
        }
        return false
    }
    
    fileprivate func read(ColorsPath jpath:String)->Bool{
        
        do {
            let fileUrl = URL(fileURLWithPath: jpath)
            let data = try Data(contentsOf: fileUrl)
            self.jsonData = JSON(data: data)
            guard let jdata = self.jsonData else {
                return false
            }
            let dataArray = jdata["color_data"].arrayValue
            for json in dataArray {
                let colorData = json.dictionaryValue
                let color = Color(withJson: colorData)
                self.colorData.colorDataArray.append(color)
            }
            return true
        } catch {
            print("Fail To Create Data From File URL")
        }
        return false
    }
    
    func save(Color color:Color)->Bool{
        let jpath = IH.DOC_PATH.appending("/color_data.json")
        let jurl = URL(fileURLWithPath: jpath)
        let colorJson = color.toJson()
        do {
            if self.colorData.colorDataArray.count == 0 {
                try "{\"color_data\" : [\(colorJson)]}".write(to: jurl, atomically: true, encoding: .utf8)
                print("saved first color")
            } else {
                let jsonStr = try String(contentsOf: jurl).dropLast(2).appending(",")
                let savedJson = jsonStr.appending(colorJson).appending("]}")
                try savedJson.write(to: jurl, atomically: true, encoding: .utf8)
                print("next color saved")
            }
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func delete(Color color:Color)->Bool{
        let jpath = IH.DOC_PATH.appending("/color_data.json")
        let jurl = URL(fileURLWithPath: jpath)
        do {
            var jsonString = "{\"color_data\" : ["
            let count = self.colorData.colorDataArray.count
            var index = 0
            for _color in self.colorData.colorDataArray {
                let json = _color.toJson()
                jsonString.append(json)
                if index < count - 1 {
                    jsonString.append(",")
                }
                index += 1
            }
            jsonString.append("]}")
            try jsonString.write(to: jurl, atomically: true, encoding: .utf8)
            print("all colors are saved")
            print(jsonString)
            return true
        } catch {
            print(error)
        }
        return false
    }
}
