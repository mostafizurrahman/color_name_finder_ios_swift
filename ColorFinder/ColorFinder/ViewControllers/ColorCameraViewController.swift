//
//  ColorCameraViewController.swift
//  coloringbook
//
//  Created by Mostafizur Rahman on 19/2/18.
//  Copyright © 2018 Tapptil. All rights reserved.
//

import UIKit
import AVFoundation
class ColorCameraViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate{
    
    typealias IH = InterfaceHelper
    struct DominentColor {
        var colorCount:Int
        let pointer:UInt32
        init(pointer p:UInt32) {
            pointer = p
            colorCount = 1
        }
    }
    
    @IBOutlet weak var previewParentWidth: NSLayoutConstraint!
    @IBOutlet weak var previewParentHeight: NSLayoutConstraint!
    @IBOutlet weak var colorNameLabel: UILabel!
    let cropWidthHeight = 40
    @IBOutlet weak var colorIndicatorView: UIView!
    @IBOutlet weak var sampleView: UIView!
    var imageContext:CGContext!
    let drawingContext:CIContext = CIContext(options:nil)
    var croppedRect:CGRect = .zero
    var isStartColor:Bool = true
    var pickNonpalleteColor:Bool = false
    var sessionManager:CameraSessionManager!
    let fillLayer = CAShapeLayer()
    let colorNameObject = DBColorNames()
    
    @IBOutlet weak var previewLayerParent: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if sessionManager == nil {
            sessionManager = CameraSessionManager.init()
            sessionManager.previewLayer.isHidden = false
            sessionManager.shouldStopDelegate = true
            sessionManager.startSession()
            // Do any additional setup after loading the view.
            namePlateView.layer.cornerRadius = 8;
            namePlateView.layer.masksToBounds = true
            namePlateView.layer.borderWidth = 0.75;
            namePlateView.layer.borderColor = UIColor.gray.cgColor
            colorIndicatorView.layer.cornerRadius = 15
            colorIndicatorView.layer.masksToBounds = true
            colorIndicatorView.layer.borderColor = UIColor.green.cgColor
            colorIndicatorView.layer.borderWidth = 0.75
            let radius = sampleView.bounds.size.width / 2
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.sampleView.bounds.size.width,
                                                        height: self.sampleView.bounds.size.height), cornerRadius: 0)
            let circlePath = UIBezierPath(roundedRect: CGRect(x: 10, y: 10, width: 2 * radius - 20,
                                                              height: 2 * radius - 20), cornerRadius: radius - 10)
            path.append(circlePath)
            path.usesEvenOddFillRule = true
            
            
            fillLayer.path = path.cgPath
            fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
            fillLayer.opacity = 1
            sampleView.layer.addSublayer(fillLayer)
            sampleView.backgroundColor = UIColor.clear
            self.sessionManager.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        } else {
            sessionManager.startSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.sessionManager.stopSession()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         _ = IH.hasTopNotch
        sessionManager.previewLayer.bounds = self.previewLayerParent.frame
        sessionManager.previewLayer.position = self.previewLayerParent.center;
        sessionManager.previewLayer.masksToBounds = true
        self.previewLayerParent.layer.insertSublayer(sessionManager.previewLayer, at: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var shouldStartProcessing:Bool = true
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if shouldStartProcessing {
            shouldStartProcessing = false
            
            if imageContext == nil {
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
                let width = CVPixelBufferGetWidth(pixelBuffer)
                let height = CVPixelBufferGetHeight(pixelBuffer)
                DispatchQueue.main.async {
                    self.previewParentWidth.constant = UIScreen.main.bounds.width
                    self.previewParentHeight.constant = UIScreen.main.bounds.width * CGFloat(height) / CGFloat(width)
                    self.view.layoutIfNeeded()
                    
                    
                    self.croppedRect = CGRect(x:width / 2 - self.cropWidthHeight/2,
                                         y:height / 2 - self.cropWidthHeight/2 + (IH.hasTopNotch ? 150 : 0),
                                         width: self.cropWidthHeight,
                                         height: self.cropWidthHeight)
                    
                    _ = CGSize( width:self.cropWidthHeight, height:self.cropWidthHeight)
                    let bitsPerComponent = 8
                    let bytesPerRow = 4 * self.cropWidthHeight
                    let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
                    self.imageContext = CGContext(data: nil, width: self.cropWidthHeight, height: self.cropWidthHeight,
                                             bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow,
                                             space: colorSpace, bitmapInfo: bitmapInfo)!
                }
                
            }
            
            guard let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                self.shouldStartProcessing = true
                return
            }
            
            let cameraImage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
            
            let croppedImage = cameraImage.cropped(to: croppedRect)
            guard let cgimage = drawingContext.createCGImage(croppedImage, from: croppedRect) else {
                self.shouldStartProcessing = true
                return
            }
            let uiimage = UIImage.init(cgImage: cgimage)
            imageContext.draw(uiimage.cgImage!, in: CGRect(x:0, y:0, width:cropWidthHeight, height:cropWidthHeight))
            //            DispatchQueue.global().async {
            let totalPixels = cropWidthHeight * cropWidthHeight
            var imageData = self.imageContext.data!.bindMemory(to: UInt32.self, capacity: totalPixels)
            
            var dominantArray:[DominentColor] = [DominentColor]()
            for _ in 0..<totalPixels {
                if imageData.pointee > 0 {
                    var shouldAppend = true
                    if dominantArray.count > 0 {
                        for i in 0...dominantArray.count - 1 {
                            let colorComp = dominantArray[i]
                            let diff = colorComp.pointer > imageData.pointee ?
                                colorComp.pointer - imageData.pointee :
                                imageData.pointee - colorComp.pointer
                            if diff < 100 {
                                shouldAppend = false
                                dominantArray[i].colorCount += 1
                                break
                            }
                        }
                    }
                    if shouldAppend {
                        let color = DominentColor(pointer:imageData.pointee)
                        dominantArray.append(color)
                    }
                }
                imageData = imageData.successor()
            }
            guard var color = dominantArray.first else {
                return
            }
            if dominantArray.count > 2 {
                for i in 1...dominantArray.count - 1{
                    let c = dominantArray[i]
                    if c.colorCount > color.colorCount {
                        color = c
                    }
                }
            }
            
            let red = CGFloat((color.pointer & 0xff0000) >> 16) / 255.0
            let green = CGFloat((color.pointer & 0xff00) >> 8) / 255.0
            let blue = CGFloat((color.pointer & 0xff) >> 0) / 255.0
            if last_rgb.shouldCheckColor(r:red, g:green, b:blue) {
                let averageColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1)
                let colorName = self.colorNameObject.name(for: red, green: green, blue: blue)
                DispatchQueue.main.async {
                    if colorName != "" {
                        self.colorNameLabel.text = colorName
                    }
                    self.fillLayer.fillColor = averageColor.cgColor
                    self.last_rgb = LastRGB.init(r:red, g:green, b:blue)
                    self.shouldStartProcessing = true
                    
                }
            } else {
                self.shouldStartProcessing = true
            }
        }
    }
    
    deinit {
        print("camera deinit")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.captureColor(UIButton())
    }
    
    @IBOutlet weak var namePlateView: UIView!
    
    
    @IBAction func saveColor(_ sender: Any) {
        let color = Color(r: Int(self.last_rgb.red * 2.55),
                              g: Int(self.last_rgb.green * 2.55),
                              b: Int(self.last_rgb.blue * 2.55))
        if ColorData.shared.add(Color: color) {
            let alert = UIAlertController(title: "Color saved to color bank",
                                          message: "Continue to capture nature colors...",
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
    
    
    @IBAction func exitColorCamera(_ sender: Any) {
        if let navigation = self.navigationController {
            if navigation.viewControllers.count == 1{
                navigation.dismiss(animated: true) {
                    self.dismiss(animated: false) {
                        
                    }
                }
            } else {
                navigation.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    @IBAction func captureColor(_ sender: Any) {
        let pickedColor = UIColor.init(red: self.last_rgb.red,
                                       green: self.last_rgb.green,
                                       blue: self.last_rgb.blue,
                                       alpha: 1)
        
    }
    
    var last_rgb:LastRGB = LastRGB.init(r: 0, g: 0, b: 0)
    struct LastRGB {
        let red:CGFloat
        let green:CGFloat
        let blue:CGFloat
        init (r:CGFloat,g:CGFloat,b:CGFloat){
            red = r
            green = g
            blue = b
            
        }
        
        func shouldCheckColor(r:CGFloat,g:CGFloat,b:CGFloat)->Bool {
            return fabs(Double(r - red)) > 0.075 ||
            fabs(Double(g - green)) > 0.075 ||
            fabs(Double(b - blue)) > 0.075
        }
    }
    
}

