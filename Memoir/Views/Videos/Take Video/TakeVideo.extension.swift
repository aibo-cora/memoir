//
//  TakeVideo.extension.swift
//  Memoir
//
//  Created by Yura on 11/10/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices

extension VideoAssetViewController: UIImagePickerControllerDelegate {
    
    func configureCamera() {
        Utility.startCamera(delegate: self, sourceType: .camera, mediaType: kUTTypeMovie as String)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String) else { return }
        let videoURL = info[.mediaURL] as? URL
        
        picker.dismiss(animated: true) {
            Utility.createAsset(using: nil, using: videoURL)
        }
    }
}
