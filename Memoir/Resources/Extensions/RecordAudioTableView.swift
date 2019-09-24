//
//  RecordAudioTableView.swift
//  Memoir
//
//  Created by Yura on 8/22/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit
import AVKit

extension RecordAudioViewController: UITableViewDataSource, UITableViewDelegate,
AVAudioPlayerDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recording.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recordingCell = tableView.dequeueReusableCell(withIdentifier: "recordingCell") as! RecordAudioTableViewCell
        
        recordingCell.setup()
        recordingCell.textLabel?.text = recording[indexPath.row]
        
        return recordingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. Make a copy of the original file (which might already have an audio)
        // 2. Add new audio track
        // 3. Display the new file in av controller, to show user controls
        
        if let originalURL = memoir?.filePath {
            mergeTracks(videoURL: originalURL, audioURL: getAudioURL(), shouldFlipHorizontally: false) { (error, newFileURL) in
                if (newFileURL != nil) {
                    self.memoir?.filePathWithNewRecording = newFileURL
                    
                    DispatchQueue.main.async {
                        // UIView.isHidden must be used from main thread only
                       self.saveButton.isHidden = false
                    }
                    
                    if let newFile = newFileURL {
                        print("Original file with old audio track: \(originalURL)")
                        print("Video file containing new recording: \(newFile)")
                        let videoPlayerWithRecording = AVPlayer(url: newFile)
                        
                        videoPlayerWithRecording.seek(to: CMTime.zero)
                        let controller = AVPlayerViewController()
                        
                        controller.player = videoPlayerWithRecording
                        self.present(controller,
                                animated: true) {
                                    videoPlayerWithRecording.play()
                        }
                    }
                }
            }
        }
    }
    
    func getDestinationURL() -> URL? {
        // If I have multiple memoirs, I need to keep track of a copy for each one, that's why I'm adding the ID to the file name
        if let memoir = memoir {
            let destination = getDocumentsDirectory().appendingPathComponent("memoir.version.\(memoir.version).\(memoir.memoirID).mp4")
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
            } catch (let error) {
                print("Cannot remove the copy of the original file. Error: \(error)")
            }
            return destination
        } else {
            return nil
        }
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
        let newFileWithRecording: URL? = getDestinationURL()
        
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
