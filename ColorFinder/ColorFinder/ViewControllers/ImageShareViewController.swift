//
//  ShareViewController.swift
//  SocialCrop
//
//  Created by Mostafizur Rahman on 11/10/18.
//  Copyright © 2018 image-app. All rights reserved.
//

import UIKit
import Photos
import Social



class ImageShareViewController: UIViewController {

    
    
//    @IBOutlet weak var successAnimatorView: SuccessAnimation!

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView:UIView!
    @IBOutlet weak var activityMessage:UILabel!
    @IBOutlet weak var activityIcon:UIImageView!
    @IBOutlet weak var activityButton: BorderButton!
    @IBOutlet weak var saveButtonBG: UIImageView!
    @IBOutlet weak var widthLayout: NSLayoutConstraint!
    @IBOutlet weak var heightLayout: NSLayoutConstraint!
    @IBOutlet weak var bottomView: ShareView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gbimageView: UIImageView!
    var skipAniamtion = false
    var sourceImage:UIImage!
    var photoAsset:PHAsset?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "SHARE"
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.tabBarController?.tabBar.isHidden = true
        guard let __image = self.sourceImage else {
            return
        }
        self.gbimageView.image = __image
        self.imageView.image = __image
        self.saveButtonBG.layer.cornerRadius = self.saveButtonBG.frame.size.width/2
        self.saveButtonBG.layer.masksToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateImageView()
    }
    
    fileprivate func updateImageView(){
        if self.skipAniamtion {
            return
        }
        let __width = self.sourceImage.size.width
        
        let __height = self.sourceImage.size.height
        let __sratio = __width / __height
        guard let sview = self.imageView.superview else {
                return
        }
        let __rect = sview.frame 
        if __height > __width {
            self.heightLayout.constant = __rect.height - 16
            self.widthLayout.constant = self.heightLayout.constant * __sratio
        } else {
            self.widthLayout.constant = __rect.width - 16
            self.heightLayout.constant =     self.widthLayout.constant / __sratio
        }
        self.imageView.layer.shadowColor = UIColor.blue.cgColor
        self.imageView.layer.shadowOpacity = 0.3
        self.imageView.layer.shadowRadius = 10
        self.imageView.setNeedsDisplay()
        self.saveButtonBG.layer.cornerRadius = saveButtonBG.frame.width / 2
        self.saveButtonBG.layer.masksToBounds = true
        sview.layoutIfNeeded()
        InterfaceHelper.animateOpacity(toVisible: self.imageView, atDuration: 0.4) { (__finished) in
            self.skipAniamtion = true
        }
    }
    @IBAction func shareinstagram(_ sender: Any) {
        if let _ = self.photoAsset {
            self.openInstagramShare()
        } else {
            PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                switch authorizationStatus {
                case .authorized :
                    self.create()
                    break
                case .notDetermined:
                    print("not determined")
                    break
                case .restricted:
                    print("restricted")
                    break
                case .denied:
                    print("denied")
                    break
                }
            }
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
    @IBAction func exitSharing(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func hideActivity(_ sender: Any) {
        InterfaceHelper.animateOpacity(toInvisible: self.activityView,
                                       atDuration: 0.4) { (finished) in
        }
    }
    @IBAction func shareOnFacebook(_ sender: UIButton) {
        guard let __image = self.sourceImage else {
            return
        }
        self.shareOnFB(shareImage: __image, withAppName: "fb")
    }
    
    var placeholder:PHObjectPlaceholder?
    var albumAsset:PHAssetCollection?
    func create(Album name:String = "_ColorFinder_")  {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(
            with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumAsset = collection.firstObject
            self.openInstagram()
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest =
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                self.placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success,
                    let ph = self.placeholder {
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(
                        withLocalIdentifiers: [ph.localIdentifier], options: nil)
                    print(collectionFetchResult)
                    self.albumAsset = collectionFetchResult.firstObject
                    self.openInstagram()
                }
            })
        }
    }
    
    fileprivate func openInstagram(){
        if let __album = self.albumAsset,
            let image = self.sourceImage {
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = assetRequest.placeholderForCreatedAsset
                let photosAsset = PHAsset.fetchAssets(in: __album, options: nil)
                let albumChangeRequest = PHAssetCollectionChangeRequest(
                    for: __album, assets: photosAsset)
                albumChangeRequest!.addAssets([assetPlaceholder!] as NSFastEnumeration)
               
                
            }, completionHandler: { success, error in
                print("added image to album")
                let fetchOptions = PHFetchOptions()
                let desc = NSSortDescriptor.init(key: "creationDate", ascending: true)
                fetchOptions.sortDescriptors = [desc]
                
                let fetchResult = PHAsset.fetchAssets(in: __album, options: fetchOptions)
                guard let _asset = fetchResult.lastObject else {return}
                self.photoAsset = _asset
                self.openInstagramShare()
            })
        }
    }
    
    fileprivate func openInstagramShare(){
        guard let __asset = self.photoAsset else {
            return
        }
        let url_location = "instagram://library?LocalIdentifier=\(__asset.localIdentifier)"
        guard let url = URL(string: url_location) else {return}
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    public func shareOnFB(shareImage image:UIImage, withAppName app:String) {
   
        
        guard let appUrl = URL.init(string: "\(app)://app") else {return}
        let (appName, serviceType) = app.elementsEqual("fb") ? ("Facebook",SLServiceTypeFacebook) : ("Twitter",SLServiceTypeTwitter)
        if UIApplication.shared.canOpenURL(appUrl){
            guard let socialViewController = SLComposeViewController(forServiceType: serviceType) else {return}
            socialViewController.setInitialText("#colorfinder #colorimage")
            socialViewController.add(image)
            socialViewController.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                switch result {
               
                case .cancelled:
                    
                    let msg = "Your \(appName) sharing aborted! Try again later."
                    print("Cancelled")
                    self.showAlert(Msg: msg, Icon: "app_icon", Loading: false)
                case .done:
                    
                    let msg = "Your cropped image will be appeared on '\(appName)' soon! It may take some time. Thank you!"
                    self.showAlert(Msg: msg, Icon: "app_icon", Loading: false)
                }
            }
            self.present(socialViewController, animated: true) {
                
            }
        } else {
            let msg = "Your '\(appName)' sharing task is aborted! We are unable to locate your '\(appName)' app! please, Install & Login to the app. Thank you!"
            self.showAlert(Msg: msg, Icon: "app_icon", Loading: false)
            
        }
        
    }
    func showAlert(Msg msg:String, Icon icon:String? = nil,
                   Loading isLoading:Bool = true){
        DispatchQueue.main.async {
            
            if isLoading {
                self.activityButton.isHidden = true
                self.activityIndicator.startAnimating()
            } else {
                self.activityButton.isHidden = false
            }
            if let __icon = icon {
                let image = UIImage(named: __icon)
                self.activityIcon.image = image
            }
            self.activityMessage.text = msg
            InterfaceHelper.animateOpacity(toVisible: self.activityView,
                                           atDuration: 0.4) { (finished) in
            }
        }
    }
    @IBAction func saveImage(_ sender: UIButton) {
        guard let image = self.sourceImage else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            // we got back an error!
//            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        } else {
//            self.titleLabel.text = "Image Saving..."
//            self.socialStatusLabel.text = "Your image is saved in the photo library!"
//            self.successAnimatorView.isHidden = false
//            InterfaceHelper.animateOpacity(toVisible: self.socialDialogView, atDuration: 0.4) { (finish) in
//                self.successAnimatorView.animate()
//                self.showAd()
//            }
        
            
//            let ac = UIAlertController(title: "Saved!", message: "The screenshot has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        }
    }
    
    @IBAction func shareInstagram(_ sender: Any) {
//        if let image = self.sourceImage {
//            let assetUrl = ""
//            PHPhotoLibrary.shared().performChanges({
//                
//                
//                let path = "instagram://library?OpenInEditor=&LocalIdentifier=\(assetUrl)"
//                
//                if let url = URL(string: path),
//                    UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.openURL(url)
//                }
//                
//                let assetReq = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                let holder = assetReq.placeholderForCreatedAsset
//                let albumChange = PHAssetCollectionChangeRequest(for: <#T##PHAssetCollection#>, assets: <#T##PHFetchResult<PHAsset>#>
//                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: <#T##URL#>)
//            }) { (finish, error) in
//                
//            }
//        }
    }
    
    @IBAction func shareToTwitter(_ sender: UIButton) {
        
        guard let __image = self.sourceImage else {
            return
        }
        self.shareOnFB(shareImage: __image, withAppName: "twitter")
    }
    
    @IBAction func openMoreOptions(_ sender: UIButton) {
        guard let __image = self.sourceImage else {
            return
        }
        let activityController = UIActivityViewController.init(activityItems: [__image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        self.present(activityController, animated: true) {
            
        }
    }
    
    @IBAction func hideDialouge(_ sender: Any) {
//        InterfaceHelper.animateOpacity(toInvisible: self.socialDialogView, atDuration: 0.4) { (finished) in
//            self.successAnimatorView.isHidden = true
//            self.titleLabel.text = "Social Sharing"
//        }
    }
    @IBAction func exitSaveViewController(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    fileprivate func showAd(){
//        SocialCropViewController.delay(0.75, closure: {
//            guard let _hvc = UIApplication.shared.homeViewController() else {
//                return
//            }
//            _hvc.shouldPresentAd = true
//            _ = _hvc.showFAN()
//        })
        
    }
    
    @IBAction func openRootViewController(_ sender: Any) {
//        guard let _hvc = UIApplication.shared.homeViewController() else {
//            self.navigationController?.popToRootViewController(animated: true)
//            return
//        }
//        _hvc.shouldPresentAd = true
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}

extension PHPhotoLibrary {
//    func save(Image image:UIImage, Album album:String, )
}
