//
//  CreateMemoirGridController.swift
//  Memoir
//
//  Created by Yura on 8/25/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import Photos
import CoreData
import CoreLocation
import AVKit

private let reuseIdentifier = "assetLibraryCell"

let assetContentMode: PHImageContentMode = .aspectFill
let assetSize = CGSize(width: 300, height: 300)
let assetCacheManager = PHCachingImageManager()
let requestOptions = PHImageRequestOptions()

class CreateMemoirGridController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var mediaType = ""
    var cachedLibraryAssets = [PHAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestAccessToPhotos()
        collectionView.allowsMultipleSelection = true
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return cachedLibraryAssets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AssetCell
    
        //
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        // Request image from asset
        assetCacheManager.requestImage(for: cachedLibraryAssets[indexPath.row], targetSize: assetSize, contentMode: assetContentMode, options: requestOptions) { (requestedImage, dictionary) in
            if let image = requestedImage {
                // Configure the cell
                cell.setup(using: image)
            }
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let indices = collectionView.indexPathsForSelectedItems {
            if indices.count > 0 {
                if let pickButton = navigationItem.rightBarButtonItem {
                    pickButton.isEnabled = true
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let indices = collectionView.indexPathsForSelectedItems {
            if indices.isEmpty {
                if let pickButton = navigationItem.rightBarButtonItem {
                    pickButton.isEnabled = false
                }
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                            left: 20.0,
                                            bottom: 50.0,
                                            right: 20.0)

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let itemSize = availableWidth / itemsPerRow
        
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }
    
    //MARK: Navigation
    
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        cachedLibraryAssets.removeAll()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func selectAllCells(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func pickButton(_ sender: UIBarButtonItem) {
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let contentEditingRequestOptions = PHContentEditingInputRequestOptions()
        
        if let indices = self.collectionView.indexPathsForSelectedItems {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            
            for index in indices {
                let asset = cachedLibraryAssets[index.row]
                // MARK: Core Data Block
                let memoryEntity = NSEntityDescription.entity(forEntityName: "Memory", in: managedObjectContext)!
                let memory = NSManagedObject(entity: memoryEntity, insertInto: managedObjectContext)
                
                memory.setValue(0, forKey: "rating")
                memory.setValue("", forKey: "title")
                memory.setValue("", forKey: "info")
                
                // get live photo, image or movie of the asset
                asset.requestContentEditingInput(with: contentEditingRequestOptions) { (contentEditingInput, dictionary) in
                    if let contentInput = contentEditingInput {
                        
                        let date = contentInput.creationDate
                        if let creationDate = date {
                            memory.setValue(creationDate, forKey: "creationDate")
                        }
                        
                        let location = contentInput.location
                        if let assetLocation = location {
                            CLGeocoder().reverseGeocodeLocation(assetLocation) { (placemark, error) in
                                guard let placemark = placemark, error == nil else {
                                    return
                                }
                                
                                if let placemarkLocation = placemark.first {
                                    var spot = ""
                                    
                                    if let country = placemarkLocation.country {
                                        spot.append("\(country) - ")
                                    }
                                    if let city = placemarkLocation.locality {
                                        spot.append("\(city) - ")
                                    }
                                    if let neighborhood = placemarkLocation.subLocality {
                                        spot.append(neighborhood)
                                    }
                                    
                                    memory.setValue(spot, forKey: "placemark")
                                }
                            }
                        }
                    }
                }
                let videoRequestOptions = PHVideoRequestOptions()
                videoRequestOptions.deliveryMode = .highQualityFormat
                videoRequestOptions.version = .current
                
                var preset = AVAssetExportPresetHighestQuality
                if #available(iOS 11.0, *) {
                    preset = AVAssetExportPresetHEVCHighestQuality
                }

                assetCacheManager.requestExportSession(forVideo: asset, options: videoRequestOptions, exportPreset: preset) { (requestedExportSession, info) in
                    
                    if let session = requestedExportSession {
                        var settings = RenderSettings()
                        settings.videoFilename = UUID().uuidString
                        if FileManager.default.fileExists(atPath: settings.outputURL.path) {
                            do {
                                try FileManager.default.removeItem(at: settings.outputURL)
                            } catch {
                                return
                            }
                        }
                        session.fileLengthLimit = 10 * 1_000_000
                        session.outputURL = settings.outputURL
                        session.outputFileType = AVFileType.mp4
                        session.exportAsynchronously {
                            switch session.status {
                            case .completed:
                                do {
                                    let videoData = try Data(contentsOf: settings.outputURL)
                                    // Create Video, set relationship
                                    let videoEntity = NSEntityDescription.entity(forEntityName: "Video", in: managedObjectContext)!
                                    let video = NSManagedObject(entity: videoEntity, insertInto: managedObjectContext)
                                    video.setValue(videoData, forKey: "video")
                                    memory.setValue(video, forKey: "video")
                                    try FileManager.default.removeItem(at: settings.outputURL)
                                } catch {
                                    return
                                }
                                
                                Utility.saveContext(message: "Video finished exporting.")
                                NotificationCenter.default.post(name: .CoreDataAddItem, object: nil)
                            case .unknown, .waiting, .exporting:
                                print("Export in progress.")
                            case .failed, .cancelled:
                                print("Export failed or cancelled.")
                            @unknown default:
                                break
                            }
                        }
                    }
                }
                
                let targetSize = CGSize(width: 1920, height: 1080)
                assetCacheManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: requestOptions) { (requestedImage, dictionary) in
                    if let image = requestedImage {
                        // Create Thumbnail, set relationship
                        let thumbnailEntity = NSEntityDescription.entity(forEntityName: "Thumbnail", in: managedObjectContext)!
                        let thumbnail = NSManagedObject(entity: thumbnailEntity, insertInto: managedObjectContext)
                        thumbnail.setValue(image.jpegData(compressionQuality: 1), forKey: "image")
                        memory.setValue(thumbnail, forKey: "thumbnail")
                        
                        switch self.mediaType {
                        case "image":
                            memory.setValue("image", forKey: "mediaType")
                        case "video":
                            memory.setValue("video", forKey: "mediaType")
                        default:
                            break
                        }
                        Utility.saveContext(message: "Image imported.")
                        
                        NotificationCenter.default.post(name: .CoreDataAddItem, object: nil)
                    }
                }
            }
        }
        
        dismiss(animated: true) {
            
        }
    }
}
