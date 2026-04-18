//
//  Recording.swift
//  Memoir
//
//  Created by Yura on 9/10/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import CoreData
import AVKit

enum RecorderState {
    case recording
    case stopped
    case denied
}

class Recording: UIViewController {
    
    var video: Video?
    var memory: Memory?
    let settings = RenderSettings()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    // MARK:- UI Properties
    var handleView = UIView()
    var recordButton = RecordButton()
    var timeLabel = UILabel()
    var audioView = AudioVisualizerView()
    var videoView = UIView(frame: CGRect(origin: .zero, size: .zero))
    
    // MARK:- AV Properties
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var videoPlayer: AVPlayer!
    var timeObserverToken: Any!
    var mergeSuccess: Bool = false
    
    // MARK:- Right Buttons
    var saveButton = UIBarButtonItem()
    var previewButton = UIBarButtonItem()
    
    // MARK:- View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
        
        if let memory = memory {
            if let videoEntity = memory.video {
                if let video = videoEntity.video {
                    do {
                        try video.write(to: settings.outputURL)
                        setupAudioSession()
                        
                        setupHandelView()
                        setupRecordingButton()
                        setupTimeLabel()
                        setupAudioView()
                        setupVideoView()
                    } catch {
                        updateUI(.denied)
                    }
                }
            } else {
                updateUI(.denied)
            }
        }
        
        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveContext))
        previewButton = UIBarButtonItem(title: "Preview", style: .plain, target: self, action: #selector(preview))
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.rightBarButtonItems?.append(previewButton)
        if let buttons = navigationItem.rightBarButtonItems {
            for button in buttons {
                button.isEnabled = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            do {
                let settings = RenderSettings()
                if FileManager.default.fileExists(atPath: settings.audioURL.path) {
                    try FileManager.default.removeItem(at: settings.audioURL)
                }
                if FileManager.default.fileExists(atPath: settings.outputURL.path) {
                    try FileManager.default.removeItem(at: settings.outputURL)
                }
            } catch let error {
                print("Could not perform clean up. Error: \(error), \(error.localizedDescription)")
            }
        }
    }
    
    //MARK:- Setup Methods
    fileprivate func setupHandelView() {
        handleView.layer.cornerRadius = 2.5
        handleView.backgroundColor = UIColor.gray
        view.addSubview(handleView)
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.widthAnchor.constraint(equalToConstant: 37.5).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        handleView.alpha = 0
    }
    
    fileprivate func setupVideoView() {
        view.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        videoView.heightAnchor.constraint(equalToConstant: view.frame.height / 2).isActive = true

        videoPlayer = AVPlayer(url: settings.outputURL)
        
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height / 2))
        videoPlayerLayer.videoGravity = .resizeAspectFill
        
        videoView.clipsToBounds = true
        videoView.layer.addSublayer(videoPlayerLayer)
    }
    
    fileprivate func setupRecordingButton() {
        recordButton.isRecording = false
        recordButton.addTarget(self, action: #selector(handleRecording(_:)), for: .touchUpInside)
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 65).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 65 ).isActive = true
    }
    
    fileprivate func setupTimeLabel() {
        view.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -16).isActive = true
        timeLabel.text = "00:00"
        timeLabel.textColor = .gray
        timeLabel.alpha = 0
    }
    
    fileprivate func setupAudioView() {
        audioView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        view.addSubview(audioView)
        audioView.translatesAutoresizingMaskIntoConstraints = false
        audioView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        audioView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -20).isActive = true
        audioView.alpha = 0
        audioView.isHidden = true
    }
    
    private func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        
            switch recordingSession.recordPermission {
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (result) in
                    DispatchQueue.main.async {
                        if result {
                            self.updateUI(.stopped)
                        }
                        else {
                            self.updateUI(.denied)
                            let alert = UIAlertController(title:"Microphone Access Denied",
                                                        message: "Microphone access was previously denied. Please updated your Settting to change this", preferredStyle: .alert)
                            let goToSettingsAction = UIAlertAction(title: "Go to Settings",
                                                                   style: .default)
                            { (action) in
                                DispatchQueue.main.async {
                                            let url = URL(string: UIApplication.openSettingsURLString)!
                                            UIApplication.shared.open(url, options: [:])}
                            }
                            alert.addAction(goToSettingsAction)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true)
                        }
                    }
                })
                break
            case .granted:
                self.updateUI(.stopped)
                break
            case .denied:
                self.updateUI(.denied)
                let alert = UIAlertController(title:"Microphone Access Denied",
                                            message: "Microphone access was previously denied. Please updated your Settting to change this", preferredStyle: .alert)
                let goToSettingsAction = UIAlertAction(title: "Go to Settings",
                                                       style: .default)
                { (action) in
                    DispatchQueue.main.async {
                                let url = URL(string: UIApplication.openSettingsURLString)!
                                UIApplication.shared.open(url, options: [:])}
                }
                alert.addAction(goToSettingsAction)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
                break
            @unknown default:
                break
            }
        } catch {
            print("Error: Cannot find an active Audio session.")
            updateUI(.denied)
        }
    }
    
    //MARK:- Update User Interface
    private func updateUI(_ recorderState: RecorderState) {
        switch recorderState {
        case .recording:
            UIApplication.shared.isIdleTimerDisabled = true
            self.audioView.isHidden = false
            self.timeLabel.isHidden = false
            videoView.isHidden = false
            break
        case .stopped:
            UIApplication.shared.isIdleTimerDisabled = false
            self.audioView.isHidden = true
            self.timeLabel.isHidden = true
            videoView.isHidden = false
            break
        case .denied:
            UIApplication.shared.isIdleTimerDisabled = false
            self.recordButton.isHidden = true
            self.audioView.isHidden = true
            self.timeLabel.isHidden = true
            videoView.isHidden = true
            break
        }
    }
    
    //MARK:- Actions
    @objc func saveContext(_ sender: UIBarButtonItem) {
        if mergeSuccess {
            print("Save context and clean up..")
            if let video = video {
                if let delegate = self.appDelegate {
                    let managedObjectContext = delegate.persistentContainer.viewContext
                    
                    do {
                        if FileManager.default.fileExists(atPath: settings.videoWithAudio.path) {
                            try video.setValue(Data(contentsOf: settings.videoWithAudio), forKey: "video")
                            if let memory = memory {
                                memory.setValue(nil, forKey: "youtubeURL")
                            }
                        }
                        
                        try managedObjectContext.save()
                        NotificationCenter.default.post(name: .CoreDataFetchVideoAssets, object: nil)
                        try FileManager.default.removeItem(at: settings.outputURL)
                        try FileManager.default.removeItem(at: settings.audioURL)
                        try FileManager.default.removeItem(at: settings.videoWithAudio)
                        print("Memory updated with recording in Core Data.")
                        if let navigation = navigationController {
                            navigation.popViewController(animated: true)
                        }
                    } catch {
                        let alert = UIAlertController(title: "Error", message: "Unable to update video with a recording. Please try again.", preferredStyle: .alert)
                        present(alert, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func preview(_ sender: UIBarButtonItem) {
        print("Preview recording..")
        mergeTracks(videoURL: settings.outputURL, audioURL: settings.audioURL)
        { (error, videoWithAudio) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let video = videoWithAudio {
                        self.mergeSuccess = true
                        
                        let player = AVPlayer(url: video)
                        let controller = AVPlayerViewController()
                        
                        controller.view.frame = self.view.frame
                        controller.player = player
                        
                        self.present(controller,animated: true) {
                            player.play()
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleRecording(_ sender: RecordButton) {
        if audioRecorder == nil {
            audioView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.handleView.alpha = 1
                self.timeLabel.alpha = 1
                self.audioView.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)
            startRecording()
        } else {
            audioView.isHidden = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.handleView.alpha = 0
                self.timeLabel.alpha = 0
                self.audioView.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
            stopRecording()
        }
    }
    
    fileprivate func startRecording() {
        let recorderSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let settings = RenderSettings()
        
        do {
            audioRecorder = try AVAudioRecorder(url: settings.audioURL, settings: recorderSettings)
            audioRecorder.delegate = self
            
            let videoAsset = AVURLAsset(url: settings.outputURL, options: nil)
            let videoDuration = videoAsset.duration
            
            audioRecorder.record(forDuration: CMTimeGetSeconds(videoDuration))
            startVideoPlayback()
        } catch {
            
        }
        
        recordButton.isRecording = true
        updateUI(.recording)
    }
    
    fileprivate func stopRecording() {
        recordButton.isRecording = false
        updateUI(.stopped)
        
        if let token = timeObserverToken {
            videoPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
        if let recorder = audioRecorder {
            recorder.stop()
        }
        audioRecorder = nil
        if let player = videoPlayer {
            player.pause()
        }
    }
    
    fileprivate func startVideoPlayback() {
        timeObserverToken = videoPlayer.addPeriodicTimeObserver(forInterval:
            CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main)
        { [weak self] time in
            let seconds = Int(CMTimeGetSeconds(time))
            self?.timeLabel.text = String(format: "%02d:%02d", seconds / 60, seconds % 60)
        }
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.isMuted = true
        videoPlayer.play()
    }
}

extension Recording: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // display "Preview" and "Save"
        if let token = timeObserverToken {
            videoPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
        updateUI(.stopped)
        mergeSuccess = false
        recordButton.isRecording = false
        if flag {
            if let buttons = navigationItem.rightBarButtonItems {
                for button in buttons {
                    button.isEnabled = true
                }
            }
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
            case AVAssetExportSession.Status.completed:
                print("Successfully saved file with new recording")
                completion(nil, newFileWithRecording)
            case AVAssetExportSession.Status.failed:
                print("Export session failed \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            case AVAssetExportSession.Status.cancelled:
                print("Export session cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            default:
                print("Export session default option, no file")
                completion(assetExport.error, nil)
            }
        }

    }
}
