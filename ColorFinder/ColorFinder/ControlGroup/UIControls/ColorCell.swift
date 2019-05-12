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
                self.shadowColor.text = "Shadow"
                self.invertColor.text = "Invert"
                self.homoColor.text = "Homo"
                self.invertColorView.layer.cornerRadius = self.invertColorView.frame.width / 2
                self.invertColorView.layer.masksToBounds = true
                self.shadowColorView.layer.cornerRadius = self.invertColorView.frame.width / 2
                self.shadowColorView.layer.masksToBounds = true
                self.homoColorView.layer.cornerRadius = self.invertColorView.frame.width / 2
                self.homoColorView.layer.masksToBounds = true
//                self.colorValue.text = 
            }
        }
    }
    
    @IBOutlet weak var bottomColorView: UIView!
    
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
    
    @IBAction func copyToClipboard(_ sender: Any) {
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        UIColor.white.setFill()
        path.fill()
        self.colorParentView.layer.cornerRadius = 10
        self.colorParentView.layer.masksToBounds = true
    }
}
