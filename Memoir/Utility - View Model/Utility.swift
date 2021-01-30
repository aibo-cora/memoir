//
//  Utility.swift
//  Memoir
//
//  Created by Yura on 11/10/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import Foundation
import AVKit
import MobileCoreServices
import CoreData
import GoogleSignIn

class Utility {
    /// Launches camera feed to take a photo or video.
    /// - Parameters:
    ///   - delegate: Either Photo or Video View Controller
    ///   - sourceType: Camera
    ///   - mediaType: Image or Movie
    static func startCamera(
      delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
        sourceType: UIImagePickerController.SourceType, mediaType: String = kUTTypeImage as String
    ) {
      guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }

      let mediaUI = UIImagePickerController()
      mediaUI.sourceType = sourceType
      mediaUI.mediaTypes = [mediaType]
      mediaUI.delegate = delegate
        
      delegate.present(mediaUI, animated: true, completion: nil)
    }
    /// Create a new asset based on whether it is a Photo or a Movie.
    /// - Parameters:
    ///   - image: Photo.
    ///   - movieURL: Movie URL.
    static func createAsset(using image: UIImage? = nil, using movieURL: URL? = nil) {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let memoryEntity = NSEntityDescription.entity(forEntityName: "Memory", in: managedObjectContext)!
        let memory = NSManagedObject(entity: memoryEntity, insertInto: managedObjectContext)
        
        memory.setValue(0, forKey: "rating")
        memory.setValue("", forKey: "title")
        memory.setValue("", forKey: "info")
        memory.setValue(Date(), forKey: "creationDate")
        
        // Create thumbnail, set relationship
        let thumbnailEntity = NSEntityDescription.entity(forEntityName: "Thumbnail", in: managedObjectContext)!
        let thumbnail = NSManagedObject(entity: thumbnailEntity, insertInto: managedObjectContext)
        
        if let image = image {
            thumbnail.setValue(image.jpegData(compressionQuality: 1), forKey: "image")
            
            memory.setValue("image", forKey: "mediaType")
        }
        if let movieURL = movieURL {
            thumbnail.setValue(movieURL.generateThumbnail()?.jpegData(compressionQuality: 1), forKey: "image")
            
            let videoData = try? Data(contentsOf: movieURL)
            let videoEntity = NSEntityDescription.entity(forEntityName: "Video", in: managedObjectContext)!
            let video = NSManagedObject(entity: videoEntity, insertInto: managedObjectContext)
            video.setValue(videoData, forKey: "video")
            
            memory.setValue("video", forKey: "mediaType")
            memory.setValue(video, forKey: "video")
        }
        
        memory.setValue(thumbnail, forKey: "thumbnail")
        
        Utility.saveContext(message: "New asset created.")
        
        NotificationCenter.default.post(name: .CoreDataAddItem, object: nil)
    }
    
    /// Upload video to YouTube
    static func uploadVideo(delegate: VideoAssetViewController, asset: CustomAsset) {
        let success = UIAlertController(title: "Success", message: "The movie was uploaded to your YouTube channel. You can now share the link with others.", preferredStyle: .alert)
        let failure = UIAlertController(title: "Failure", message: "The movie could not be uploaded to your YouTube channel. Please try again later.", preferredStyle: .alert)
        
        if let _ = GIDSignIn.sharedInstance()?.currentUser {
            if let videoEntity = asset.memory.video {
                if let videoData =  videoEntity.video {
                    do {
                        let settings = RenderSettings()
                        
                        if FileManager.default.fileExists(atPath: settings.outputURL.path) {
                            try FileManager.default.removeItem(at: settings.outputURL)
                        }
                        try videoData.write(to: settings.outputURL)
                        
                        delegate.uploadToYouTube(filePath: settings.outputURL, videoStory: asset.memory.story)
                        { (isUploaded, link) in
                            if isUploaded {
                                delegate.present(success, animated: true) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        delegate.dismiss(animated: true, completion: nil)
                                    }
                                }
                                asset.memory.youtubeURL = link
                                Utility.saveContext(message: "Memory uploaded to YouTube and updated in Core Data.")
                            } else {
                                delegate.present(failure, animated: true) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        delegate.dismiss(animated: true, completion: nil)
                                    }
                                }
                                asset.memory.youtubeURL = nil
                                Utility.saveContext(message: "Memory failed to upload to YouTube and updated in Core Data.")
                            }
                            DispatchQueue.main.async {
                                delegate.snapshotForCurrentState()
                            }
                            
                            do {
                                if FileManager.default.fileExists(atPath: settings.outputURL.path) {
                                    try FileManager.default.removeItem(at: settings.outputURL)
                                }
                            } catch {
                                print("Error: Failed to remove file that was uploaded to YouTube")
                            }
                        }
                    } catch {
                        print("Error: Failed to write file to disk to be uploaded to YouTube")
                    }
                }
            }
        } else {
            // No user is logged in
            let alert = UIAlertController(title: "Upload Error", message: "Please log in to your Google account in Settings before attempting to upload.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            delegate.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Save context.
    /// - Parameter context: Current working context.
    /// - Parameter message: Message.
    static func saveContext(message: String? = nil) {
        DispatchQueue.main.async {
            guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
              return
            }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            
            do {
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
            } catch let error {
                print("Could not save into Core Data. Error: \(error.localizedDescription)")
            }
        }
        
        if let message = message {
            print(message)
        }
    }
    
    static var selectedMemoryToPreview: Memory?
}
