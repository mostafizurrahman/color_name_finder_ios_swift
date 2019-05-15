//
//  AlbumManager.swift
//  TextOnPhoto
//
//  Created by Mostafizur Rahman on 26/2/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit
import Photos


class AlbumManager: NSObject {
    
    fileprivate let photoOptions = PHImageRequestOptions()
    let fetchOptions = PHFetchOptions()
    static let shared = AlbumManager()
    var readingMedia = false
    
    var selectedIndex = -1
    var titleName : String = ""
    var selectedArray:[PHAsset] = []
    var tmpTitle:String = ""
    var tmpArray:[PHAsset] = []
    
    
    override init() {
        super.init()
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            switch authorizationStatus {
            case .authorized :
                self.readMediaData()
                break
            case .notDetermined:
                print("not determined")
                break
            case .restricted:
                print("restricted")
                break
            case .denied:
                let notificationName = Notification.Name(rawValue: "media_reading_denied")
                NotificationCenter.default.post(name: notificationName, object: nil)
                print("denied")
                break
            }
        }
    }
    
    var albumTitleArray:[String] = []
    var albumCollection:[String:[PHAsset]] = [:]
    fileprivate func readMediaData(){
        self.readingMedia = true
        let sortOrder = NSSortDescriptor.init(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortOrder]
        photoOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        
        let mediaTypes = [PHAssetCollectionType.album,
                           PHAssetCollectionType.moment,
                           PHAssetCollectionType.smartAlbum]
        for index in 0..<mediaTypes.count {
            let media_type = mediaTypes[index]
            let media_collections:PHFetchResult<PHAssetCollection> =
                PHAssetCollection.fetchAssetCollections(with: media_type,
                                                        subtype: PHAssetCollectionSubtype.any,
                                                        options: nil)
            if media_collections.count > 0 {
                for album_index in 0..<media_collections.count {
                    let album_asset = media_collections[album_index]
                    guard var __album_name = album_asset.localizedTitle else {
                        continue
                    }
                    if __album_name.lowercased().contains("camera roll"){
                        __album_name = "Camera Roll"
                    }
                    if self.albumTitleArray.contains(__album_name) {
                        guard let photo_asset_array = self.albumCollection[__album_name] else {
                            continue
                        }
                        self.append(From: album_asset, albumName: __album_name,inArray:photo_asset_array)
                    } else {
                        self.append(From: album_asset, albumName: __album_name)
                        self.albumTitleArray.append(__album_name)
                    }
                    if __album_name.lowercased().contains("recent"){
                        self.titleName = __album_name
                    }
                }
            }
        }
        self.setSelectedAlbum()
    }
    
    fileprivate func setSelectedAlbum(){
        guard let photo_asset_array = self.albumCollection["Camera Roll"] else {
            if let first = self.albumTitleArray.first,
                let photo_asset_array = self.albumCollection[first] {
                self.titleName = "\(first) 🔻"
                self.selectedArray = photo_asset_array
                self.sendNotification()
            }
            return
        }
        self.titleName = "Camera Roll 🔻"
        self.selectedArray = photo_asset_array
        self.sendNotification()
    }
    
    fileprivate func sendNotification() {
        self.readingMedia = false
        let notificationName = Notification.Name(rawValue: "media_reading_done")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    
    fileprivate func append(From album_asset:PHAssetCollection,
                           albumName __album_name:String,
                           inArray _photo_asset_array:[PHAsset] = []) {
        let photo_asset_list = PHAsset.fetchAssets(in: album_asset, options: fetchOptions)
//        if photo_asset_list.count == 0 {
//            return
//        }
        var photo_asset_array = _photo_asset_array
        for asset_index in 0..<photo_asset_list.count {
            let photo = photo_asset_list[asset_index]
            if photo.sourceType == PHAssetSourceType.typeUserLibrary{
                photo_asset_array.append(photo)
            }
        }
//        if photo_asset_array.count == 0 {
//            return
//        }
        self.albumCollection[__album_name] = photo_asset_array
    }
    
    func requestImage(for asset: PHAsset,
                      targetSize: CGSize,
                      contentMode: PHImageContentMode = PHImageContentMode.aspectFill,
                      completionHandler: @escaping (UIImage?) -> ()) {
        let imageManager = PHImageManager()
        imageManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: PHImageContentMode.default,
                                  options: self.photoOptions) { (image, _) in
                                    completionHandler(image)
        }
    }
    var placeholder:PHObjectPlaceholder?
    var albumAsset:PHAssetCollection?
    func create(Album name:String = "Text On Image", Image image:UIImage? = nil)  {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any,
                                                                                         options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumAsset = collection.firstObject
            print(self.albumAsset?.localizedTitle ?? "none")
            if let __image = image {
                self.write(Image: __image)
            }
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                self.placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success,
                    let ph = self.placeholder {
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [ph.localIdentifier], options: nil)
                    print(collectionFetchResult)
                    self.albumAsset = collectionFetchResult.firstObject
                    if let __image = image {
                        self.write(Image: __image)
                    }
                }
            })
        }
    }
    
    var localIdentifier = ""
    
    fileprivate func write(Image image:UIImage){
        guard let __album = self.albumAsset else { return }
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let assetPlaceholder = assetRequest.placeholderForCreatedAsset else {return}
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: __album) else {return}
            albumChangeRequest.addAssets([assetPlaceholder] as NSFastEnumeration)
            self.localIdentifier = assetPlaceholder.localIdentifier
            
        }, completionHandler: { success, error in
            let assets:PHFetchResult = PHAsset.fetchAssets(
                withLocalIdentifiers: [self.localIdentifier], options: nil)
            if let asset = assets.firstObject {
                self.selectedArray.insert(asset, at: 0)
                self.albumCollection[self.titleName.replacingOccurrences(of: " 🔻", with: "")] = self.selectedArray
            }
            let notificationName = Notification.Name(rawValue: "media_reading_done")
            NotificationCenter.default.post(name: notificationName, object: nil)
        })
    }
    
    func save(Image image:UIImage){
        let albumName = self.titleName.replacingOccurrences(of: " 🔻", with: "")
        self.create(Album:albumName,Image: image)
    }
}
