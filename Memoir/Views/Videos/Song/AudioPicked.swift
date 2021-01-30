//
//  AudioPicked.swift
//  Memoir
//
//  Created by Yura on 9/17/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import MediaPlayer

extension SongViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true)
        
        if let mediaItem = mediaItemCollection.items.first {
            audioAssetURL =  mediaItem.assetURL
            
            let mediaItemTitle = NSMutableAttributedString(string: "")
            
            if let artist = mediaItem.artist {
                mediaItemTitle.append(NSAttributedString(string: artist, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy)]))
            }
            mediaItemTitle.append(NSAttributedString(string: " - "))
            if let title = mediaItem.title {
                mediaItemTitle.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light)]))
            }
            pickAudio.setAttributedTitle(mediaItemTitle, for: .normal)
            
            previewButton.isEnabled = true
            saveButton.isEnabled = true
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true) {
            
        }
    }
}
