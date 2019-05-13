//
//  ColorCell.swift
//  ColorFinder
//
//  Created by NoboPay on 12/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    var color:Color? {
        didSet {
            if let c = self.color {
                let _c =  c.toColor()
                self.colorView.backgroundColor = _c
                self.bottomColorView.backgroundColor = _c.withAlphaComponent(0.4)
                self.red.text = "\(c.red)"
                self.green.text = "\(c.green)"
                self.blue.text = "\(c.blue)"
                self.layer.shadowColor = _c.cgColor
                let hexvalue:String = String(NSString(format:"%2X", c.intRGB))
                self.colorValue.text = hexvalue
                let homo = ColorGenerator.ColorHomo(red: UInt8(c.red),
                                                    green: UInt8(c.green),
                                                    blue: UInt8(c.blue),
                                                    hueAngle: 30)
                self.homoColorView.backgroundColor = UIColor.init(red: CGFloat(homo.r) / 255.0,
                                                                  green: CGFloat(homo.g) / 255.0,
                                                                  blue: CGFloat(homo.b) / 255.0, alpha: 1)
                
                let invert = ColorGenerator.ColorInvert(red: UInt8(c.red),
                                                    green: UInt8(c.green),
                                                    blue: UInt8(c.blue),
                                                    hueAngle: 0)
                self.invertColorView.backgroundColor = UIColor.init(red: CGFloat(invert.r) / 255.0,
                                                                  green: CGFloat(invert.g) / 255.0,
                                                                  blue: CGFloat(invert.b) / 255.0, alpha: 1)
                
                let shadow = ColorGenerator.ColorShade(red: UInt8(c.red),
                                                    green: UInt8(c.green),
                                                    blue: UInt8(c.blue),
                                                    blackPercent: 80)
                self.shadowColorView.backgroundColor = UIColor.init(red: CGFloat(shadow.r) / 255.0,
                                                                  green: CGFloat(shadow.g) / 255.0,
                                                                  blue: CGFloat(shadow.b) / 255.0, alpha: 1)
            }
        }
    }
    
    @IBOutlet weak var bottomColorView: UIView!
    
    @IBOutlet weak var greenview: UIView!
    @IBOutlet weak var redview: UIView!
    @IBOutlet weak var colorParentView: UIView!
    @IBOutlet weak var red: UILabel!
    @IBOutlet weak var green: UILabel!
    @IBOutlet weak var blue: UILabel!
    @IBOutlet weak var colorValue: UILabel!
    @IBOutlet weak var homoColor: UILabel!
    @IBOutlet weak var invertColor: UILabel!
    @IBOutlet weak var shadowColor: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var homoColorView: UIView!
    @IBOutlet weak var invertColorView: UIView!
    @IBOutlet weak var shadowColorView: UIView!
    @IBOutlet weak var blueview: UIView!
    
    @IBAction func copyToClipboard(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shadowColor.text = "Shadow"
        self.invertColor.text = "Invert"
        self.homoColor.text = "Homo"
        self.invertColorView.layer.cornerRadius = self.invertColorView.frame.width / 2
        self.invertColorView.layer.masksToBounds = true
        self.shadowColorView.layer.cornerRadius = self.invertColorView.frame.width / 2
        self.shadowColorView.layer.masksToBounds = true
        self.homoColorView.layer.cornerRadius = self.invertColorView.frame.width / 2
        self.homoColorView.layer.masksToBounds = true
        self.redview.layer.cornerRadius = self.redview.frame.width / 2
        self.redview.layer.masksToBounds = true
        self.greenview.layer.cornerRadius = self.redview.frame.width / 2
        self.greenview.layer.masksToBounds = true
        self.blueview.layer.cornerRadius = self.redview.frame.width / 2
        self.blueview.layer.masksToBounds = true

    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        UIColor.white.setFill()
        path.fill()
        self.colorParentView.layer.cornerRadius = 10
        self.colorParentView.layer.masksToBounds = true
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 10
    }
}
