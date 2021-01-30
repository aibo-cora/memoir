//
//  TakePhoto.extension.swift
//  Memoir
//
//  Created by Yura on 11/6/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import Foundation
import MobileCoreServices

extension PhotoAssetsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func configureCamera() {
        Utility.startCamera(delegate: self, sourceType: .camera)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                  mediaType == (kUTTypeImage as String) else { return }
            let photo = info[.originalImage] as? UIImage
            
            picker.dismiss(animated: true) {
                Utility.createAsset(using: photo, using: nil)
            }
    }
}
