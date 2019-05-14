//
//  ViewController.swift
//  Example
//
//  Created by Louis D'hauwe on 02/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

	@IBOutlet weak var colorSquarePicker: ColorSquarePicker!
	@IBOutlet weak var colorIndicatorView: ColorIndicatorView!
	
	@IBOutlet weak var rLabel: UILabel!
	@IBOutlet weak var gLabel: UILabel!
	@IBOutlet weak var bLabel: UILabel!

	@IBOutlet weak var hLabel: UILabel!
	@IBOutlet weak var sLabel: UILabel!
	@IBOutlet weak var vLabel: UILabel!
	
	@IBOutlet weak var hexLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

        if let colorPicker = self.colorSquarePicker {
            didChangeColor(colorPicker.color)
        }

	}

	@IBAction func colorBarPickerValueChanged(_ sender: ColorBarPicker) {
		
		colorSquarePicker.hue = sender.hue
		didChangeColor(colorSquarePicker.color)

	}
	
	@IBAction func colorSquarePickerValueChanged(_ sender: ColorSquarePicker) {
		
		didChangeColor(sender.color)
		
	}
	
	func didChangeColor(_ color: UIColor) {
		
		guard let rgbValue = color.rgbValue else {
			return
		}
		
		guard let hsvValue = color.hsvValue else {
			return
		}
		
		rLabel.text = String(format: "R: %.f", rgbValue.r * 255)
		gLabel.text = String(format: "G: %.f", rgbValue.g * 255)
		bLabel.text = String(format: "B: %.f", rgbValue.b * 255)
		
		hLabel.text = String(format: "H: %.f°", hsvValue.h * 360)
		sLabel.text = String(format: "S: %.f%%", hsvValue.s * 100)
		vLabel.text = String(format: "V: %.f%%", hsvValue.v * 100)
	
		hexLabel.text = color.hexString
		colorIndicatorView.color = color
		
	}
	
}

