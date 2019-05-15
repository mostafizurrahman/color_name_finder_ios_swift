//
//  FilterViewController.swift
//  ColorFinder
//
//  Created by NoboPay on 15/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class FilterViewController: CMFilterViewController {

    @IBOutlet weak var colorSquarePicker: ColorSquarePicker!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var widthLayout: NSLayoutConstraint!
    @IBOutlet weak var heightLayout: NSLayoutConstraint!
    var colorData:FilterColorData?
    override func viewDidLoad() {
        
        guard let image = self.sourceImage else {
            return
        }
        self.imageView.image = image
        let ratio = image.size.width / image.size.height
        let percent:CGFloat = InterfaceHelper.IS_PAD ? 0.75 : 0.9
        if ratio > 1.0 {
            self.widthLayout.constant = InterfaceHelper.MS_WIDTH * percent
            self.heightLayout.constant =  InterfaceHelper.MS_WIDTH * percent / ratio
        } else {
            self.heightLayout.constant = (InterfaceHelper.MS_HEIGHT - 275) * percent
            self.widthLayout.constant =  (InterfaceHelper.MS_HEIGHT - 275) * percent * ratio
        }
        self.drawing_glk_view.layoutIfNeeded()
        
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        for data in self.drawing_glk_view.filterParamArray {
            if let filterData = data as? FilterColorData {
                self.colorData = filterData
            }
        }
        
        self.drawing_glk_view.layoutIfNeeded()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneColoring(_ sender: UIBarButtonItem) {
        if let image = self.drawing_glk_view.getImage() {
            self.performSegue(withIdentifier: "ShareSegue", sender: image)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let idf = segue.identifier {
            if idf.elementsEqual("ShareSegue") {
                if let dest = segue.destination as? ImageShareViewController {
                    dest.sourceImage = sender as? UIImage
                }
            }
        }
    }
    
    @IBAction func colorBarPickerValueChanged(_ sender: ColorBarPicker) {
        DispatchQueue.main.async {
            self.colorSquarePicker.hue = sender.hue
            if let color = self.colorData {
                color.inputColor =  CIColor(color: self.colorSquarePicker.color)
                self.drawing_glk_view.setColorData(color)
            }
        }
    }
    
    deinit {
        self.drawing_glk_view.deleteDrawable()
        self.drawing_glk_view.deleteContext()
    }
    
    @IBAction func colorSquarePickerValueChanged(_ sender: ColorSquarePicker) {
        if let color = self.colorData {
            color.inputColor = CIColor(color: sender.color)
            self.drawing_glk_view.setColorData(color)
        }
//        didChangeColor(sender.color)
        
    }
}
