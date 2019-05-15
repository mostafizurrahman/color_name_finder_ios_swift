//
//  ViewController.swift
//  TextOnPhoto
//
//  Created by Mostafizur Rahman on 26/2/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit
import Photos


class AlbumViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate  {
    
    
    typealias IH = InterfaceHelper
    @IBOutlet weak var authButton: UIButton!
    let albumManager = AlbumManager.shared
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var titleButton: UIButton!
    fileprivate var selectedColor = UIColor.black.withAlphaComponent(0.25)
    @IBOutlet weak var collectionTopLayout: NSLayoutConstraint!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    private var maxCount = -1
    private var imageAssetArray:[PHAsset] = []
    private var chacheArray:[String:UIImage] = [:]
    private var thumbSize:CGSize = .zero
    var selectedIndex = 0
    var originalHeight:CGFloat = -1
    var minimumHeight:CGFloat = 75
    var whRatio:CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMediaReadingDone(_ :)),
                                               name: Notification.Name(rawValue: "media_reading_done"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMediaReadingDenied(_ :)),
                                               name: Notification.Name(rawValue: "media_reading_denied"),
                                               object: nil)
        let dim  = widthHeight * UIScreen.main.scale
        self.thumbSize = CGSize(width:dim, height: dim)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func openPermissionSettings(_ sender: Any) {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if PHPhotoLibrary.authorizationStatus() == .denied {
            self.authButton.isHidden  = false
            self.photosCollectionView.isHidden = true
        } else {
            self.authButton.isHidden  = true
            self.photosCollectionView.isHidden = false
        }
        if  !albumManager.readingMedia {
            self.onMediaReadingDone(Notification(name: Notification.Name.init("media_reading_done")))
        }
    }
    
    let widthHeight = CGFloat(UIScreen.main.bounds.width / (UIDevice.current.userInterfaceIdiom == .pad ? 6.0 : 3.0))  - 3
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    @objc func onMediaReadingDenied(_ norification:Notification){
        DispatchQueue.main.async {
            
            
        }
    }
    
    @objc func onMediaReadingDone(_ norification:Notification){
        DispatchQueue.main.async {
            self.selectedIndex = 0
            let array =  self.albumManager.selectedArray
            self.imageAssetArray = array
            self.titleButton.setTitle(self.albumManager.titleName, for: .normal)
            self.photosCollectionView.reloadData()
            if self.visualEffectView != nil {
                self.visualEffectView.removeFromSuperview()
            }
        }
        //        super.removeAD(norification)
    }
    
    @IBAction func openAlbum(_ sender:Any){
        self.performSegue(withIdentifier: "AlbumSegue", sender: self)
    }
    
    
    @IBAction func openCamera(_ sender: UIBarButtonItem) {
        
        self.checkPermission()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo
        info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //            self.previewImageView.image = image
            self.albumManager.save(Image: image)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    let picker = UIImagePickerController()
    
    func checkPermission() {
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            self.picker.delegate = self
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true) {() -> Void in }
        case .denied:
            self.openPermissionSettings(UIButton())
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (finish) in
                switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video){
                case .authorized:
                    self.picker.delegate = self
                    self.picker.sourceType = .camera
                    self.present(self.picker, animated: true) {() -> Void in }
                case .denied:
                    print("Error")
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let idf = segue.identifier {
            if idf.elementsEqual("ColorSegue") {
                self.tabBarController?.tabBar.isHidden = true
                if let dest = segue.destination as? FilterViewController {
                    if let image = sender as? UIImage {
                        dest.sourceImage = image
                    }
                }
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension String {
    func localized(withComment:String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
}


extension AlbumViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if maxCount < indexPaths.count {
            maxCount = indexPaths.count
        }
        for indexPath in indexPaths {
            let asset = self.imageAssetArray[indexPath.row]
            let key = asset.localIdentifier
            
            self.albumManager.requestImage(for: asset, targetSize:self.thumbSize ) { (thumbImage) in
                DispatchQueue.main.async {
                    self.chacheArray[key] = thumbImage
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthHeight, height: widthHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let __cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let selectView = __cell.viewWithTag(3214) {
            if self.selectedIndex == indexPath.row {
                selectView.backgroundColor = self.selectedColor
                //self.setImage(Index: indexPath)
            } else {
                selectView.backgroundColor = .clear
            }
        }
        
        if let imageView = __cell.viewWithTag(1234) as? UIImageView {
            let asset = self.imageAssetArray[indexPath.row]
            if let image = self.chacheArray[asset.localIdentifier] {
                imageView.image = image
            } else {
                self.albumManager.requestImage(for: asset, targetSize:self.thumbSize ) { (thumbImage) in
                    DispatchQueue.main.async {
                        imageView.image = thumbImage
                    }
                }
            }
        }
        
        return __cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageAssetArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedIndex = IndexPath(row: self.selectedIndex, section: 0)
        if let selectedCell = collectionView.cellForItem(at: selectedIndex) {
            if let selectView = selectedCell.viewWithTag(3214) {
                selectView.backgroundColor = .clear
            }
        }
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            if let selectView = selectedCell.viewWithTag(3214) {
                selectView.backgroundColor = self.selectedColor
            }
        }
        self.setImage(Index: indexPath)
        self.selectedIndex = indexPath.row
    }

    fileprivate func setImage(Index indexPath:IndexPath){
        let asset = self.imageAssetArray[indexPath.row]
        var skipSegue = true
        self.albumManager.requestImage(for: asset,
                                       targetSize:CGSize(width: asset.pixelWidth,
                                                         height: asset.pixelHeight) ) { (thumbImage) in
                                                            DispatchQueue.main.async {
                                                                if !skipSegue {
                                                                    self.performSegue(withIdentifier: "ColorSegue", sender: thumbImage)
                                                                }
                                                                skipSegue = false
                                                                //self.previewImageView.image = thumbImage
                                                            }
        }
    }
    
    
}


