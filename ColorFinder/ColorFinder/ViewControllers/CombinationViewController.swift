//
//  CombinationViewController.swift
//  ColorFinder
//
//  Created by NoboPay on 14/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class CombinationViewController: BaseViewController {
    
    var colorData:Color?
    
    
    @IBOutlet weak var colorDetails: UILabel!
    @IBOutlet weak var bottomPicker: ColorIndicatorView!
    @IBOutlet weak var bottom2Picker: ColorIndicatorView!
    @IBOutlet weak var top2Picker: ColorIndicatorView!
    @IBOutlet weak var topPicker: ColorIndicatorView!
    @IBOutlet weak var centerPicker: ColorIndicatorView!
    var selectedPicker:ColorIndicatorView?
    @IBOutlet weak var widthLayout: NSLayoutConstraint!
    @IBOutlet weak var heightLayout: NSLayoutConstraint!
    
    @IBOutlet weak var titlelabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if InterfaceHelper.IS_PAD {
            self.heightLayout.constant = InterfaceHelper.MS_WIDTH * 0.5
            self.widthLayout.constant = self.heightLayout.constant
        } else {
            self.heightLayout.constant = InterfaceHelper.MS_WIDTH * 0.85
            self.widthLayout.constant = self.heightLayout.constant
        }
        if let color = self.colorData {
            self.centerPicker.color = color.toColor()
            self.colorDetails.textAlignment = .center
            self.titlelabel.text = "Homogenous Colors"
            self.colorDetails.text = "Primary Color : \(color.colorTitle)\n\(color.toColor().hexString)"
        }
        self.changeColor(Type: 0)
        for view in [self.bottomPicker, self.centerPicker, self.bottom2Picker, self.topPicker, self.top2Picker] {
            view?.layer.borderColor = UIColor.red.cgColor
            view?.layer.borderWidth = 0
            view?.layer.cornerRadius = (view?.frame.size.width ?? 75.0) / 2
            view?.layer.masksToBounds = true
            let pan = UITapGestureRecognizer(target: self, action: #selector(selectedColor(_ :)))
            pan.numberOfTapsRequired = 1
            view?.addGestureRecognizer(pan)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    deinit {
        for view in [self.bottomPicker, self.centerPicker, self.bottom2Picker, self.topPicker, self.top2Picker] {
            if let gesture = view?.gestureRecognizers?.first {
                view?.removeGestureRecognizer(gesture)
            }
        }
    }
    
    @objc func selectedColor( _ sender:UITapGestureRecognizer){
        if let _sp = self.selectedPicker {
            _sp.layer.borderWidth = 0
        }
        self.selectedPicker = sender.view as? ColorIndicatorView
        sender.view?.layer.borderWidth = 5
        if let _sp = self.selectedPicker {
            self.titlelabel.textColor = _sp.color
            let text = self.titlelabel.text
            self.titlelabel.text = "Color Copied!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.titlelabel.text = text
                self.titlelabel.textColor = UIColor.black
            }
            UIPasteboard.general.string = _sp.color.hexString.replacingOccurrences(of: "#", with: "")
        }
    }
    
    @IBAction func changeColorType(_ sender: UISegmentedControl) {
        
        self.changeColor(Type: sender.selectedSegmentIndex)
        
    }
    
    
    fileprivate func changeColor(Type type:Int){
        guard let _color = self.colorData else {return}
        if let _sp = self.selectedPicker {
            _sp.layer.borderWidth = 0
        }
        if type == 0 {
            self.titlelabel.text = "Homogenous Colors"
            let color1 = ColorGenerator.ColorHomo(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: 15)
            self.topPicker.color = UIColor(red: CGFloat(CGFloat(color1.r) / 255.0), green: CGFloat(CGFloat(color1.g) / 255.0),
                                           blue: CGFloat(CGFloat(color1.b) / 255.0), alpha: 1.0)
            let color2 = ColorGenerator.ColorHomo(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: -15)
            self.top2Picker.color =  UIColor(red: CGFloat(CGFloat(color2.r) / 255.0), green: CGFloat(CGFloat(color2.g) / 255.0),
                                             blue: CGFloat(CGFloat(color2.b) / 255.0), alpha: 1.0)
            let color3 = ColorGenerator.ColorHomo(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: 30)
            self.bottom2Picker.color = UIColor(red: CGFloat(CGFloat(color3.r) / 255.0), green: CGFloat(CGFloat(color3.g) / 255.0),
                                               blue: CGFloat(CGFloat(color3.b) / 255.0), alpha: 1.0)
            let color4 = ColorGenerator.ColorHomo(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: -35)
            self.bottomPicker.color = UIColor(red: CGFloat(CGFloat(color4.r) / 255.0), green: CGFloat(CGFloat(color4.g) / 255.0),
                                              blue: CGFloat(CGFloat(color4.b) / 255.0), alpha: 1.0)
        } else if type == 1 {
            self.titlelabel.text = "Invert Colors"
            let color1 = ColorGenerator.ColorInvert(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: 15)
            self.topPicker.color = UIColor(red: CGFloat(CGFloat(color1.r) / 255.0), green: CGFloat(CGFloat(color1.g) / 255.0),
                                           blue: CGFloat(CGFloat(color1.b) / 255.0), alpha: 1.0)
            let color2 = ColorGenerator.ColorInvert(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: -15)
            self.top2Picker.color = UIColor(red: CGFloat(CGFloat(color2.r) / 255.0), green: CGFloat(CGFloat(color2.g) / 255.0),
                                            blue: CGFloat(CGFloat(color2.b) / 255.0), alpha: 1.0)
            let color3 = ColorGenerator.ColorInvert(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: 30)
            self.bottom2Picker.color = UIColor(red: CGFloat(CGFloat(color3.r) / 255.0), green: CGFloat(CGFloat(color3.g) / 255.0),
                                               blue: CGFloat(CGFloat(color3.b) / 255.0), alpha: 1.0)
            let color4 = ColorGenerator.ColorInvert(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  hueAngle: -35)
            self.bottomPicker.color = UIColor(red: CGFloat(CGFloat(color4.r) / 255.0), green: CGFloat(CGFloat(color4.g) / 255.0),
                                             blue: CGFloat(CGFloat(color4.b) / 255.0), alpha: 1.0)
        } else if type == 2 {
            self.titlelabel.text = "Colors With Black"
            let color1 = ColorGenerator.ColorShade(red: UInt8(_color.red ),
                                                  green: UInt8(_color.green ),
                                                  blue: UInt8(_color.blue ),
                                                  blackPercent: 90)
            self.topPicker.color = UIColor(red: CGFloat(CGFloat(color1.r) / 255.0), green: CGFloat(CGFloat(color1.g) / 255.0),
                                          blue: CGFloat(CGFloat(color1.b) / 255.0), alpha: 1.0)
            let color2 = ColorGenerator.ColorShade(red: UInt8(_color.red ),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  blackPercent: 70)
            self.top2Picker.color = UIColor(red: CGFloat(CGFloat(color2.r) / 255.0), green: CGFloat(CGFloat(color2.g) / 255.0),
                                            blue: CGFloat(CGFloat(color2.b) / 255.0), alpha: 1.0)
            let color3 = ColorGenerator.ColorShade(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  blackPercent: 55)
            self.bottom2Picker.color = UIColor(red: CGFloat(CGFloat(color3.r) / 255.0), green: CGFloat(CGFloat(color3.g) / 255.0),
                                               blue: CGFloat(CGFloat(color3.b) / 255.0), alpha: 1.0)
            let color4 = ColorGenerator.ColorShade(red: UInt8(_color.red),
                                                  green: UInt8(_color.green),
                                                  blue: UInt8(_color.blue),
                                                  blackPercent: 45)
            self.bottomPicker.color = UIColor(red: CGFloat(CGFloat(color4.r) / 255.0), green: CGFloat(CGFloat(color4.g) / 255.0),
                                              blue: CGFloat(CGFloat(color4.b) / 255.0), alpha: 1.0)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
