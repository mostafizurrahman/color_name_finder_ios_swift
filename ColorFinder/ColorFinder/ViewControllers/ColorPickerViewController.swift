//
//  ColorPickerViewController.swift
//  ColorFinder
//
//  Created by NoboPay on 14/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    
    var last_rgb:UIColor?
    @IBOutlet weak var colorSaveButton: UIButton!
    
    @IBOutlet weak var _rgb: NSLayoutConstraint!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        if InterfaceHelper.IS_PAD {
            self._rgb.constant = InterfaceHelper.MS_WIDTH * 0.35
        } else {
            self._rgb.constant = InterfaceHelper.MS_WIDTH * 0.75
        }
        if let colorPicker = self.colorSquarePicker {
            didChangeColor(colorPicker.color)
        }
        
    }
    
    @IBAction func colorBarPickerValueChanged(_ sender: ColorBarPicker) {
        DispatchQueue.main.async {
            self.colorSquarePicker.hue = sender.hue
            self.didChangeColor(self.colorSquarePicker.color)
        }
    }
    
    @IBAction func colorSquarePickerValueChanged(_ sender: ColorSquarePicker) {
        
        didChangeColor(sender.color)
        
    }
    let nameGen = DBColorNames()
    @IBAction func saveColor(_ sender: Any) {
        guard let rgb = self.last_rgb else {return}
        guard let _rgb = rgb.rgbValue else {return}
        guard let cname = self.nameGen.name(for: rgb) else {return}
        UIPasteboard.general.string = rgb.hexString.replacingOccurrences(of: "#", with: "")
        let color = Color(r: Int(_rgb.r * 255),
                          g: Int(_rgb.g * 255),
                          b: Int(_rgb.b * 255), _title: cname)
        if ColorData.shared.add(Color: color) {
            let alert = UIAlertController(title: "COLOR SAVED & COPIED",
                                          message: "Continue to pickup colors...",
                                          preferredStyle: .actionSheet)
            if let pop = alert.popoverPresentationController {
                pop.permittedArrowDirections = []
                pop.sourceView = self.view
                pop.sourceRect = CGRect(origin: CGPoint(x: self.view.frame.midX, y: self.view.frame.midY), size: .zero)
            }
            let action = UIAlertAction(title: "CONTINUE", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            let notification = Notification.init(name: Notification.Name.init("color_saved"))
            NotificationCenter.default.post(notification)
        }
        
    }
    func didChangeColor(_ color: UIColor) {
        
        guard let rgbValue = color.rgbValue else {
            return
        }
        
        guard let hsvValue = color.hsvValue else {
            return
        }
        self.last_rgb = color
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

extension UIColor {
    
    public var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
}
