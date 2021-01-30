//
//  Create.extension.swift
//  Memoir
//
//  Created by Yura on 8/25/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import Photos

extension CreateMemoirGridController {
    
    func requestAccessToPhotos() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    self.cacheAssetsFromLibrary()
                case .notDetermined:
                    if status == PHAuthorizationStatus.authorized {
                        self.cacheAssetsFromLibrary()
                    }
                case .denied, .restricted, .limited:
                    DispatchQueue.main.async {
                        let alert =
                            UIAlertController(title: "Photo Library Access restricted",
                            message: "Photo Library access was previously restricted. Please updated your Settting to change this",
                                                      preferredStyle: .alert)
                        let goToSettingsAction = UIAlertAction(title: "Go to Settings",
                                                               style: .default)
                        { (action) in
                            DispatchQueue.main.async {
                                let url = URL(string: UIApplication.openSettingsURLString)!
                                UIApplication.shared.open(url, options: [:])}
                        }
                        alert.addAction(goToSettingsAction)
                        alert.addAction(UIAlertAction(title: "Cancel",
                                                      style: .cancel))
                        self.present(alert,
                                     animated: true)
                    }
                @unknown default:
                    break
                }
            }
        }
    }
    
    fileprivate func cacheAssetsFromLibrary() {        
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        var results = PHFetchResult<PHAsset>()
        
        switch mediaType {
        case "image":
            results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        case "video":
            results = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        default:
            break
        }
        
        if results.count > 0 {
            for count in 0..<results.count {
                cachedLibraryAssets.append(results.object(at: count))
            }
            
        }
        assetCacheManager.startCachingImages(for: cachedLibraryAssets, targetSize: assetSize, contentMode: assetContentMode, options: requestOptions)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
