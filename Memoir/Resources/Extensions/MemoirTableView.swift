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
        return 160
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
                                        title: "Upload")
        { (action, view, actionPerformed: @escaping (Bool) -> (Void)) in
                                            actionPerformed(true)
            GIDSignIn.sharedInstance()?.signIn()
            MemoirFunctions.uploadToYouTube(fileToUpload: MemoirData.memoirData[indexPath.row].filePath!,
                                            callback:
                { (success) in
                    if success {
                        print("Success! Video uploaded to your YouTube channel")
                    } else {
                        print("Error: Video upload unsuccessful")
                    }
            })
        }
        
        upload.backgroundColor = UIColor.clear
        upload.image = #imageLiteral(resourceName: "youtube.icon")
        
        return UISwipeActionsConfiguration(actions: [upload])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fileToPreview = MemoirData.memoirData[indexPath.row].filePath else {
            return
            // if filePath was not set
        }
        
        let player = AVPlayer(url: fileToPreview)
        let controller = AVPlayerViewController()
        
        controller.player = player
        present(controller,
                animated: true) {
                    player.play()
        }
        
    }
}
