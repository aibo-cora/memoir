//
//  AddMemoirViewController.swift
//  Memoir
//
//  Created by Yura on 7/20/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit
import Photos

class AddMemoirViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memoirNameTextField: UITextField!
    
    var doneSaving: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.addShadowRoundedCorners()
        popupView.backgroundColor = Theme.accent
        
        titleLabel.font = UIFont(name: Theme.mainFontName, size: 24)
        titleLabel.textColor = Theme.tint
        imageView.layer.cornerRadius = 10
    }

    @IBAction func save(_ sender: UIButton) {
        // Use .rightView in case you want to display an image in the textfield
//        memoirNameTextField.rightViewMode = .never
        
        guard memoirNameTextField.text != "", let _ = memoirNameTextField.text else {
            memoirNameTextField.layer.borderColor = UIColor.red.cgColor
            memoirNameTextField.layer.borderWidth = 1
            memoirNameTextField.layer.cornerRadius = 5
            memoirNameTextField.placeholder = "Memoir name required..."
//            memoirNameTextField.rightViewMode = .always
            return
        }
        dismiss(animated: true) {
            if let done = self.doneSaving {
//                MemoirFunctions.createMemoir(memoir: Memoir(title: newMemoirName))
                done()
            }
        }
    }
    
    @IBAction func cencel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    fileprivate func presentPickerController() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker,
                     animated: true)
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    self.presentPickerController()
                case .notDetermined:
                    if status == PHAuthorizationStatus.authorized {
                        self.presentPickerController()
                    }
                case .restricted:
                    let alert = UIAlertController(title: "Photo Library Restricted",
                                                  message: "Photo Library access is restricted and cannot be accessed",
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK",
                                                 style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                case .denied:
                    let alert = UIAlertController(title: "Photo Library Access Denied",
                                                  message: "Photo Library access was previously denied. Please updated your Settting to change this",
                                                  preferredStyle: .alert)
                    let goToSettingsAction = UIAlertAction(title: "Go to Settings",
                                                 style: .default) { (action) in
                                                    DispatchQueue.main.async {
                                                        let url = URL(string: UIApplication.openSettingsURLString)!
                                                        UIApplication.shared.open(url, options: [:])
                                                    }
                                                    
                    }
                    alert.addAction(goToSettingsAction)
                    alert.addAction(UIAlertAction(title: "Cancel",
                                                  style: .cancel))
                    self.present(alert,
                                 animated: true)
                @unknown default:
                    break
                }
            }
        }
        
    }
    
}


extension AddMemoirViewController: UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
        }
        
        dismiss(animated: true) {
            // code after image was selected
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // code if Cencel was selected
        dismiss(animated: true)
    }
}
