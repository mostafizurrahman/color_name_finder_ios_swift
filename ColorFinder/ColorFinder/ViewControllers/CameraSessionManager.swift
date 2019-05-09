//
//  CameraSessionManager.swift
//  coloringbook
//
//  Created by Paradox Lab on 12/26/17.
//  Copyright © 2017 Tapptil. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreGraphics



class CameraSessionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
 
    
    public var previewLayer:AVCaptureVideoPreviewLayer!
    public var captureSession:AVCaptureSession!
    private var videoDevice:AVCaptureDevice!
    private var usingBackCamera:Bool = false
    fileprivate var shouldStopRendering = false
    var shouldStopDelegate = false;
    private var imageConnection:AVCaptureConnection!
    private var imageDataOutput:AVCaptureStillImageOutput!
    let videoBufferQueue  = DispatchQueue.init(label: "QUEUE_NAME_VIDEO")
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoConnection: AVCaptureConnection!
    

    
    
    override init(){
        super.init()
        initializeSession()
        
    }

    

    
    func initializeSession(){
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        setSessionVideoDevice()
        configureCaptureImageOutput()
        setVideoDataOutptFromSession()
        configurePreviewLayer()
    }
    
    func setSessionVideoDevice()  {
//        videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let vdevices = AVCaptureDevice.devices(for: AVMediaType.video)
        
        
        for device in vdevices{
            if device.position == AVCaptureDevice.Position.back{
                videoDevice = device
            }
        }
        do {
            let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            captureSession.addInput(deviceInput)
        } catch {
            
        }
    }
    
    func configureCaptureImageOutput() {
        imageDataOutput = AVCaptureStillImageOutput()
        imageDataOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        captureSession.addOutput(imageDataOutput)
        imageConnection = imageDataOutput.connection(with: AVMediaType.video)
        imageConnection.videoOrientation = AVCaptureVideoOrientation.portrait
    }
    
    func configurePreviewLayer(){
        
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        self.previewLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    func startSession(){
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    
    func stopSession(){
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func setVideoDataOutptFromSession() {
        videoDataOutput = AVCaptureVideoDataOutput.init()
        videoDataOutput.videoSettings =  [kCVPixelBufferPixelFormatTypeKey : kCMPixelFormat_32BGRA] as [String : Any]
//        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        captureSession.addOutput(videoDataOutput)
        guard let connection = videoDataOutput.connection(with: AVMediaType.video) else {return}
         connection.videoOrientation = AVCaptureVideoOrientation.portrait;
      videoConnection = connection
    }

    
    func changeCamera() {
        var desiredPosition:AVCaptureDevice.Position!
        if usingBackCamera {
            desiredPosition = AVCaptureDevice.Position.front
        }
        else {
            desiredPosition = AVCaptureDevice.Position.back
        }
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for d in devices {
            if d.position == desiredPosition {
                previewLayer.session?.beginConfiguration()
                do {
                    let cameraInput = try AVCaptureDeviceInput.init(device: d)
                    let sessionInputs = previewLayer.session?.inputs
                    for oldInput in sessionInputs ?? [] {
                        previewLayer.session?.removeInput(oldInput)
                    }
                    captureSession.addInput(cameraInput)
                    
                } catch {
                    
                }
                previewLayer.session?.commitConfiguration()
                break;
            }
        }
        usingBackCamera = !usingBackCamera;
    }
    

    

    static func getRotatedImage(sourceImage:UIImage) ->UIImage{
        let iamge_size:CGSize  = sourceImage.size
        UIGraphicsBeginImageContext(iamge_size)
        sourceImage.draw(in: CGRect(x:0, y:0, width:iamge_size.width, height:iamge_size.height))
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: iamge_size.width/2, y: iamge_size.height/2)
        context?.rotate(by: CGFloat(Double.pi / 2))
        let rotatedImageRef = context?.makeImage()
        let outputImage = UIImage.init(cgImage: rotatedImageRef!)
        UIGraphicsEndImageContext()
        return outputImage
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("fired")
    }
    
 
    
}



