//
//  SongViewController.swift
//  Memoir
//
//  Created by Yura on 9/17/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import MediaPlayer

class SongViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var previewButton: UIBarButtonItem!
    
    let settings = RenderSettings()
    
    var video: Video?
    var videoPlayer: AVPlayer!
    var videoView = UIView(frame: CGRect(origin: .zero, size: .zero))
    
    var pickAudio = UIButton(type: .roundedRect)
    var audioAssetURL: URL?
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.isEnabled = false
        previewButton.isEnabled = false
        // Do any additional setup after loading the view.
        if let video = video {
            configureVideo(video: video)
            configureAudio()
        }
    }
    
    private func configureAudio() {
        view.addSubview(pickAudio)
        pickAudio.translatesAutoresizingMaskIntoConstraints = false
        pickAudio.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pickAudio.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pickAudio.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
        pickAudio.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 44))
        pickAudio.setTitle("Select Audio", for: .normal)
        pickAudio.setImage(UIImage(systemName: "music.note"), for: .normal)
        pickAudio.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        pickAudio.titleLabel?.lineBreakMode = .byWordWrapping
        pickAudio.addTarget(self, action: #selector(selectAudioFromLibrary), for: .touchUpInside)
    }
    
    private func configureVideo(video: Video) {
        view.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        videoView.heightAnchor.constraint(equalToConstant: view.frame.height / 2).isActive = true
        
        let settings = RenderSettings()
        do {
            try video.video?.write(to: settings.outputURL)
        } catch {
            let alert = UIAlertController(title: "Error", message: "Corrupted video data.", preferredStyle: .alert)
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return
        }
        videoPlayer = AVPlayer(url: settings.outputURL)
        
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height / 2))
        videoPlayerLayer.videoGravity = .resizeAspectFill
        
        videoView.clipsToBounds = true
        videoView.layer.addSublayer(videoPlayerLayer)
    }
    // MARK: Actions
    @objc func selectAudioFromLibrary() {
        let controller = MPMediaPickerController(mediaTypes: .music)
                            
        controller.allowsPickingMultipleItems = false
        controller.popoverPresentationController?.sourceView = self.view
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let videoEntity = video {
            if let delegate = self.appDelegate {
                let managedObjectContext = delegate.persistentContainer.viewContext
                do {
                    if FileManager.default.fileExists(atPath: settings.videoWithAudio.path) {
                        try videoEntity.setValue(Data(contentsOf: settings.videoWithAudio), forKey: "video")
                        if let memory = videoEntity.memory {
                            memory.setValue(nil, forKey: "youtubeURL")
                        }
                    }
                    try managedObjectContext.save()
                    NotificationCenter.default.post(name: .CoreDataFetchVideoAssets, object: nil)
                    try FileManager.default.removeItem(at: settings.outputURL)
                    try FileManager.default.removeItem(at: settings.audioURL)
                    try FileManager.default.removeItem(at: settings.videoWithAudio)
                    
                    print("Memory updated with a new audio track in Core Data.")
                    if let navigation = navigationController {
                        navigation.popViewController(animated: true)
                    }
                } catch {
                    let alert = UIAlertController(title: "Error", message: "Unable to update video with a new audio track. Please try again.", preferredStyle: .alert)
                    present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    return
                }
            }
        }
    }
    
    @IBAction func preview(_ sender: UIBarButtonItem) {
        videoPlayer.pause()
        videoPlayer.seek(to: CMTime.zero)
        if let assetURL = audioAssetURL {
            if removeAudioURL() {
                
                let asset = AVURLAsset(url: assetURL)
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
                    return
                }
                print(settings.audioURL)
                exportSession.outputURL = settings.audioURL
                exportSession.outputFileType = AVFileType.m4a
                exportSession.exportAsynchronously {
                    if exportSession.status == .completed {
                        self.mergeTracks(videoURL: self.settings.outputURL, audioURL: self.settings.audioURL) { (error, url) in
                            
                            if let finalURL = url {
                                self.videoPlayer.replaceCurrentItem(with: AVPlayerItem(url: finalURL))
                                self.videoPlayer.volume = 1
                                self.videoPlayer.play()
                            } else {
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "Error", message: "Export session failed.", preferredStyle: .alert)
                                    self.present(alert, animated: true) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func removeAudioURL() -> Bool {
        if FileManager.default.fileExists(atPath: settings.audioURL.path) {
            do {
                try FileManager.default.removeItem(at: settings.audioURL)
            } catch {
                return false
            }
        }
        return true
    }
    
    func mergeTracks(videoURL: URL,
                     audioURL: URL,
                     shouldFlipHorizontally: Bool = false,
                     completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioTrack = [AVMutableCompositionTrack]()
        
        let aVideoAsset = AVAsset(url: videoURL)
        let aAudioAsset = AVAsset(url: audioURL)
        
        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        // Default must have transformation
        compositionAddVideo?.preferredTransform = aVideoAssetTrack.preferredTransform
        
        if shouldFlipHorizontally {
            // true if video was recorded using frontal camera, otherwise false
            var frontalTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            frontalTransform = frontalTransform.translatedBy(x: -aVideoAssetTrack.naturalSize.width, y: 0.0)
            frontalTransform = frontalTransform.translatedBy(x: 0.0, y: -aVideoAssetTrack.naturalSize.width)
            compositionAddVideo?.preferredTransform = frontalTransform
        }
        
        if let videoComposition = compositionAddVideo {
            mutableCompositionVideoTrack.append(videoComposition)
        }
        if let audioComposition = compositionAddAudio {
            mutableCompositionAudioTrack.append(audioComposition)
        }
        
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRange(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aVideoAssetTrack,
                                                                at: CMTime.zero)
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRange(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aAudioAssetTrack,
                                                                at: CMTime.zero)
        } catch {
            print(error.localizedDescription)
        }
        
        // Exporting
        if FileManager.default.fileExists(atPath: settings.videoWithAudio.path) {
            do {
                try FileManager.default.removeItem(at: settings.videoWithAudio)
            } catch {
                
            }
        }
        let newFileWithRecording: URL? = settings.videoWithAudio
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = newFileWithRecording
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSessionStatus.completed:
                print("Successfully saved file with new recording")
                completion(nil, newFileWithRecording)
            case AVAssetExportSessionStatus.failed:
                print("Export session failed \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            case AVAssetExportSessionStatus.cancelled:
                print("Export session cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            default:
                print("Export session default option, no file")
                completion(assetExport.error, nil)
            }
        }

    }
}
