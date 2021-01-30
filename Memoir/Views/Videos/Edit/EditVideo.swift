//
//  EditVideo.swift
//  Memoir
//
//  Created by Yura on 9/21/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit

extension VideoAssetViewController: UIVideoEditorControllerDelegate, UINavigationControllerDelegate {
    
    /// After user taps "Save", the editor exports the new file to the URL that was provided as path for original file
    /// - Parameters:
    ///   - editor: video editor
    ///   - editedVideoPath: output URL
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        
        let alert = UIAlertController(title: "Confirm Overwrite...", message: "The edited version of the video will overwrite the original. Please confirm.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .destructive, handler: { (alertAction) in
            DispatchQueue.main.async {
                if let videoEntity = self.videoBeingEdited {
                    do {
                        try videoEntity.video = Data(contentsOf: URL(fileURLWithPath: editedVideoPath))
                        
                        Utility.saveContext(message: "The original video was successfully replaced with the edited version.")
                        
                        let alert = UIAlertController(title: "Success", message: "The original video was successfully replaced with the edited version.", preferredStyle: .alert)
                        NotificationCenter.default.post(name: .CoreDataAddItem, object: nil)
                        editor.dismiss(animated: true) {
                            self.present(alert, animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    } catch {
                        let alert = UIAlertController(title: "Error", message: "Could not save video. Please try again.", preferredStyle: .alert)
                        editor.present(alert, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }))
        editor.present(alert, animated: true)
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        editor.dismiss(animated: true)
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        
        let alert = UIAlertController(title: "Error.", message: error.localizedDescription, preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
