//
//  RecordAudioViewController.swift
//  Memoir
//
//  Created by Yura on 8/15/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit
import AVKit

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var handleView: UIView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var recordView: RecordAnimationView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var playbackTimerLabel: UILabel!
    @IBOutlet weak var recordingTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var videoPlayer: AVPlayer!
    
    var timeObserverToken: Any!
    var recording = [String]()
    
    var memoir: Memoir?
    
    enum State {
        case idle, record, play
    }
    
    var state = State.idle
    
    fileprivate func setupHandleView() {
        handleView.layer.cornerRadius = 25
        handleView.backgroundColor = UIColor.black
        handleView.isHidden = false
    }
    
    fileprivate func setupRecordButton() {
        whiteView.backgroundColor = UIColor.white
        whiteView.layer.cornerRadius = whiteView.frame.width / 2
        
        backView.backgroundColor = UIColor.black
        backView.layer.cornerRadius = backView.frame.width / 2
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getAudioURL() -> URL {
        if let memoirID = memoir?.memoirID {
            return getDocumentsDirectory().appendingPathComponent("audioRecording.\(memoirID).m4a")
        }
        return getDocumentsDirectory().appendingPathComponent("audioRecording.noMemoir.m4a")
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if audioRecorder == nil {
            saveButton.isHidden = true
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func finishRecording(success: Bool) {
        // If a time observer exists, remove it
        if let token = timeObserverToken {
            videoPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
        audioRecorder.stop()
        audioRecorder = nil
        
        videoPlayer.pause()
        
        if success {
            
        } else {
            let alert = UIAlertController(title: "Failed to record",
                                          message: "There was a problem recording your message. Please try again",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: .default,
                                          handler: { (action) in
                                            // failed to record, clean up
            }))
            present(alert, animated: true)
        }
    }
    
    func startVideoPlayback() {
        timeObserverToken = videoPlayer.addPeriodicTimeObserver(forInterval:
            CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main)
        { [weak self] time in
            let seconds = Int(CMTimeGetSeconds(time))
            self?.playbackTimerLabel.text = String(format: "%02d:%02d", seconds / 60, seconds % 60)
        }
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.isMuted = true
        videoPlayer.play()
    }
    
    func startRecording() {
        // TODO: Check if user wants to discard old recording (if present)
        state = State.record
        
        let audioURL = getAudioURL()
        print(audioURL)
        
        let recorderSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL,
                                                settings: recorderSettings)
            audioRecorder.delegate = self
            if (memoir?.slideShowImages.count == 1) {
                audioRecorder.record(forDuration: 10)
            } else {
                audioRecorder.record(forDuration: TimeInterval((memoir?.slideShowImages.count)! * 5))
            }
            recordView.animateRecord()
            startVideoPlayback()
            
            recording.removeAll()
            recordingTableView.reloadData()
        } catch {
            finishRecording(success: false)
        }
    }
    /* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // clean up, combine audio and video
        if (flag) {
            state = State.idle
            recordView.animateStop()
            print("A voice recording was successfully saved...")
            // If a time observer exists, remove it
            if let token = timeObserverToken {
                videoPlayer.removeTimeObserver(token)
                timeObserverToken = nil
            }
            let date = Date()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            let message = "Play the recording made on: " + dateString
            recording.append(message)
            recordingTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isHidden = true
        handleView.isHidden = true
        playbackTimerLabel.isHidden = true
        
        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        
        setupAudioSession()
    }
    
    func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadPermissionDeniedUI()
                        
                        let alert = UIAlertController(title:
                                                        "Microphone Access Denied",
                                                      message: "Microphone access was previously denied. Please updated your Settting to change this",
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
                }
            }
        } catch {
            loadPermissionDeniedUI()
            // The device is not ready to activate an Audio Session
        }
    }
    
    func loadRecordingUI() {
        setupHandleView()
        setupRecordButton()
        showVideoView()
        view.backgroundColor = UIColor.black
        recordingTableView.backgroundColor = UIColor.black
        recordingTableView.isHidden = false
        playbackTimerLabel.isHidden = false
        playbackTimerLabel.textColor = UIColor.white
    }
    
    func loadPermissionDeniedUI() {
        // Settings -> Privacy -> Microphone
        
        recordingTableView.isHidden = true
        playbackTimerLabel.isHidden = true
        handleView.isHidden = true
    }
    
    func showVideoView() {
        let videoFrame = CGRect(origin: CGPoint.zero,
                                size: CGSize(width: view.frame.width,
                                             height: 300))
        guard let fileToPreview = memoir?.filePath else {
            return
            // if filePath was not set
        }
        
        videoPlayer = AVPlayer(url: fileToPreview)
        
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer.frame = videoFrame
        videoPlayerLayer.videoGravity = .resizeAspectFill
        videoPlayerLayer.cornerRadius = 25
        
        videoPlayerView.layer.cornerRadius = 25
        videoPlayerView.layer.addSublayer(videoPlayerLayer)
    }
    
    @IBAction func close(_ sender: UIButton) {
        if state == State.record {
            // wind down the recording, it was interrupted
            // TODO: Display an alert. "Are you sure you want to cancel recording?" Yes/Continue
            finishRecording(success: true)
        }
        if recording.isEmpty {
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Confirm Discard Changes",
                                          message: "You made a recording. Are you sure you want to discard it?",
                                          preferredStyle: .alert)
            let discard = UIAlertAction(title: "Discard",
                                        style: .destructive)
            { (alertAction) in
                                            self.recording.removeAll()
                                            self.dismiss(animated: true)
                let audioRecording = self.getAudioURL()
                do {
                    if let memoir = self.memoir {
                        let fileWithNewRecording = self.getDocumentsDirectory().appendingPathComponent("memoir.version.\(memoir.version).\(memoir.memoirID).mp4")
                        if FileManager.default.fileExists(atPath: fileWithNewRecording.path) {
                            try FileManager.default.removeItem(at: fileWithNewRecording)
                        }
                    }
                    if FileManager.default.fileExists(atPath: audioRecording.path) {
                        try FileManager.default.removeItem(at: audioRecording)
                    }
                } catch (let error) {
                    print("Cannot remove the audio recording file. Error: \(error)")
                }
            }
            
            let keep = UIAlertAction(title: "Keep",
                                     style: .default,
                                     handler: nil)
            
            alert.addAction(discard)
            alert.addAction(keep)
            present(alert, animated: true)
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        let alert = UIAlertController(title: "Replace Audio Track",
                                      message: "Choose Save if you want to replace the old audio track with the new recording",
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: nil)
        let replace = UIAlertAction(title: "Replace",
                                    style: .default)
        { (alertAction) in
            // this is where i need to delete and replace files
            // display success message, dismiss view
            do {
                if let filePath = self.memoir?.filePath {
                    if FileManager.default.fileExists(atPath: filePath.path) {
                        try FileManager.default.removeItem(at: filePath)
                        try FileManager.default.removeItem(at: self.getAudioURL())
                    }
                }
            } catch (let error) {
                print("Cannot remove file. Error: \(error)")
            }
            
            self.memoir?.filePath = self.memoir?.filePathWithNewRecording
            self.memoir?.filePathWithNewRecording = nil
            self.memoir?.version += 1
            MemoirFunctions.saveMemoirsToFile()
            
            self.dismiss(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(replace)
        present(alert, animated: true)
    }
    
}
