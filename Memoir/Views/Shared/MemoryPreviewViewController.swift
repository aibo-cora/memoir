//
//  PreviewViewController.swift
//  Memoir
//
//  Created by Yura on 8/31/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import PhotosUI

class MemoryPreviewViewController: UIViewController {

    private let photoView = UIImageView()
    private let livePhotoView = PHLivePhotoView()
    private var playerView = UIView()
    private var isVideo: Bool = false
    
    private var memory: Memory? = nil
    
    var player: AVPlayer!

    init(memory: Memory) {
        super.init(nibName: nil, bundle: nil)
        
        self.memory = memory
        if let type = memory.mediaType {
            switch type {
            case "image":
                if let thumbnail = memory.thumbnail {
                    if let data = thumbnail.image {
                        let photo = UIImage(data: data)
                        if let image = photo {
                            photoView.image = image
                            preferredContentSize = image.size
                        }
                    }
                }
                isVideo = false
            case "video":
                isVideo = true
            default:
                break
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        if isVideo {
            if let memory = self.memory {
                let settings = RenderSettings()

                if let videoEntity = memory.video {
                    if let video = videoEntity.video {
                        do {
                            if FileManager.default.fileExists(atPath: settings.outputURL.path) {
                                try FileManager.default.removeItem(at: settings.outputURL)
                            }
                            try video.write(to: settings.outputURL)
                        } catch {
                            print("Video file not created.")
                        }
                        player = AVPlayer(url: settings.outputURL)
                        let playerLayer = AVPlayerLayer(player: player)
                        
                        playerView.bounds.size = CGSize(width: 400, height: 400)
                        preferredContentSize = CGSize(width: 400, height: 400)
                        playerLayer.frame = playerView.bounds
                        playerLayer.videoGravity = .resizeAspectFill
                        playerView.layer.addSublayer(playerLayer)
                        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        
                        player.play()
                    }
                }
            }
            view = playerView
        } else {
            photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view = photoView
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let player = player {
            player.pause()
        }
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(assetDeleted(_:)), name: .AssetDeleted, object: nil)
    }
    
    @objc fileprivate func assetDeleted(_ notification: NSNotification) {
        player?.pause()
    }
}
