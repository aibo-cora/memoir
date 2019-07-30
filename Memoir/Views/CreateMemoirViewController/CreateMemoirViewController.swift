//
//  CreateMemoirViewController.swift
//  Memoir
//
//  Created by Yura on 7/24/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit
import Photos

class CreateMemoirViewController: UIViewController {
    @IBOutlet weak var bottomLayerView: UIView!
    @IBOutlet weak var tableViewContainerView: UIView!    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var memoirTitleTF: UITextField!
    
    @IBOutlet weak var memoirTitleDesc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        CreateMemoirTableData.tableData.removeAll()
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        
        bottomLayerView.backgroundColor = Theme.accent
        bottomLayerView.addShadowRoundedCorners()
        tableViewContainerView.addDeeperShadowRoundedCorners()
        tableView.addShadowRoundedCorners()
        
        cancelButton.makeFloatingActionButton()
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.makeFloatingActionButton()
        saveButton.setTitleColor(UIColor.white, for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
//        memoirTitleDesc.font = UIFont(name: Theme.mainFontName, size: 10)
//        memoirTitleDesc.textColor = Theme.tint
//        memoirTitleDesc.text = "Add a short title to your memoir."
        
        memoirTitleTF.placeholder = "\"Bahamas\", \"My Story\"..."
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            // "cancel" button completion
            CreateMemoirTableData.tableData.removeAll()
        }
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        // TODO: Value check
        let newMemoir = Memoir(title: memoirTitleTF.text)
        
        newMemoir.slideShowImages = CreateMemoirTableData.tableData
        if let indexPathSelected = tableView.indexPathForSelectedRow {
            newMemoir.image = CreateMemoirTableData.tableData[indexPathSelected.row]
        }
        
        MemoirData.memoirData.append(newMemoir)
        dismiss(animated: true) {
            MemoirFunctions.buildMovie(memoir: newMemoir)
            
        }
        
    }
    
    fileprivate func presentPickerController() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
//        picker.mediaTypes = [String(kUTTMediaMovie)]
        self.present(picker,
                     animated: true)
    }
    
    @IBAction func selectImageButtonPressed(_ sender: UIButton) {
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


extension CreateMemoirViewController: UINavigationControllerDelegate,
                                        UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            CreateMemoirTableData.tableData.append(image)
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 1.0
        }
        
        dismiss(animated: true) {
            // code after image was selected
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(row: CreateMemoirTableData.tableData.count - 1, section: 0),
                                       at: .middle,
                                       animated: true)
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0),
                                     animated: true,
                                     scrollPosition: .none)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // code if Cencel was selected
        dismiss(animated: true)
    }
}

extension CreateMemoirViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreateMemoirTableData.tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let createMemoirTableCell = tableView.dequeueReusableCell(withIdentifier: "createMemoirTableViewCell") as! ImageViewTableViewCell
        
        createMemoirTableCell.setupCell(at: indexPath.row + 1, using: CreateMemoirTableData.tableData[indexPath.row])
        
        return createMemoirTableCell
    }
    
}
