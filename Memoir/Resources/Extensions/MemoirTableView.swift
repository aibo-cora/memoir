//
//  MemoirTableViewExtension.swift
//  Memoir
//
//  Created by Yura on 7/17/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import GoogleSignIn
import UIKit
import AVKit

extension MemoirViewController: UITableViewDataSource,
                                UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemoirData.memoirData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let memoirCell = tableView.dequeueReusableCell(withIdentifier: "memoirCell") as! MemoirTableViewCell
        
        
        memoirCell.setup(memoir: MemoirData.memoirData[indexPath.row])
        return memoirCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive,
                                        title: "Delete")
        { (action, view, actionPerformed: @escaping (Bool) -> (Void)) in
            let alert = UIAlertController(title: "Confirm Delete Memoir",
                                        message: "Are you sure you want to delete this Memoir?",
                                 preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "No",
                                       style: .cancel,
                                     handler: { (action) in
                                                    actionPerformed(false)
                                            })
            let delete = UIAlertAction(title: "Delete",
                                       style: .destructive,
                                       handler: { (action) in
                                                // perform delete
                                                MemoirFunctions.deleteMemoir(index: indexPath.row)
                                                //  tableView.reloadData()
                                                tableView.deleteRows(at: [indexPath],
                                                                     with: .automatic)
                                                actionPerformed(true)
                                        if MemoirData.memoirData.count == 0 {
                                            self.directions.text = "Tap this button to add a slideshow"
                                        }
                                            })
                                        
            alert.addAction(cancel)
            alert.addAction(delete)
            self.present(alert, animated: true)
        }
        delete.title = "Trash"
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let upload = UIContextualAction(style: .normal,
                                        title: "Upload to YouTube")
        { (action, view, actionPerformed: @escaping (Bool) -> (Void)) in
                                            actionPerformed(true)
            self.uploadFile(memoir: MemoirData.memoirData[indexPath.row])
        }
        
        upload.backgroundColor = UIColor.red
 //       upload.image = #imageLiteral(resourceName: "youtube.icon")
        let share = UIContextualAction(style: .normal,
                                       title: "Share")
        { (action, view, actionPerformed: @escaping (Bool) -> (Void)) in
            actionPerformed(true)
            
            var activityItems: [Any] = [Any]()
            let alert = UIAlertController(title: "Share with others!",
                                          message: "What would you like to share?",
                                          preferredStyle: .alert)
            let shareFile = UIAlertAction(title: "Video File",
                                          style: .default,
                                          handler:
                { (alertAction) in
                    if let videoURL = MemoirData.memoirData[indexPath.row].filePath {
                        activityItems = [videoURL, "Check my video out!"]
                    }
                    
                    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    
                    activityController.popoverPresentationController?.sourceView = self.view
                    activityController.popoverPresentationController?.sourceRect = self.view.frame
                    
                    self.present(activityController, animated: true, completion: nil)
            })
            
            let shareURL = UIAlertAction(title: "Link to YouTube",
                                         style: .default,
                                         handler:
                { (alertAction) in
                    if let videoURL = MemoirData.memoirData[indexPath.row].onYoutube {
                        let urlPath = URL(string: videoURL)
                        print(urlPath)
                        activityItems = [URL(string: videoURL) as Any, "Check this link to my video out!"]
                    }
                    
                    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    
                    activityController.popoverPresentationController?.sourceView = self.view
                    activityController.popoverPresentationController?.sourceRect = self.view.frame
                    
                    self.present(activityController, animated: true, completion: nil)
            })
            
            alert.addAction(shareFile)
            alert.addAction(shareURL)
            self.present(alert, animated: true)

        }
        
        share.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        let login = UIContextualAction(style: .normal,
                                       title: "Sign In to YouTube")
        { (action, view, actionPerformed: @escaping (Bool) -> (Void)) in
            actionPerformed(true)
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.upload")
            GIDSignIn.sharedInstance().signIn()
        }
        
        login.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
 //       login.image = #imageLiteral(resourceName: "google")
        
        let record = UIContextualAction(style: .normal,
                                        title: "Record Audio")
        { (action, view, actionPerformed: @escaping (Bool) -> (Void)) in
            actionPerformed(true)
            
            let storyboard = UIStoryboard(name: String(describing: RecordAudioViewController.self),
                                          bundle: nil)
            let recordAudioViewController = storyboard.instantiateInitialViewController() as! RecordAudioViewController
            recordAudioViewController.memoir = MemoirData.memoirData[indexPath.row]
            self.present(recordAudioViewController,
                    animated: true) {
            }
        }
        
        record.backgroundColor = UIColor.blue
        
        // TODO: Check onYoutube, if true, add "Share" action
        if (GIDSignIn.sharedInstance()?.currentUser == nil) {
            // no logged in user, display login option
            return UISwipeActionsConfiguration(actions: [login])
        } else {
            return UISwipeActionsConfiguration(actions: [share, record, upload])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fileToPreview = MemoirData.memoirData[indexPath.row].filePath else {
            return
            // if filePath was not set
        }
        
        let player = AVPlayer(url: fileToPreview)
        let controller = AVPlayerViewController()
        
        controller.view.frame = CGRect (x:100, y:100, width:200, height:100)
        controller.player = player
        present(controller,
                animated: true) {
                    player.play()
        }
    }
}
