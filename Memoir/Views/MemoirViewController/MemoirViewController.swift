//
//  MemoirViewController.swift
//  Memoir
//
//  Created by Yura on 7/15/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire

class MemoirViewController: UIViewController, UIGestureRecognizerDelegate,
                            GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var directions: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signInSilently()
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        MemoirFunctions.showMemoirs { [weak self] in
            // completion
            self?.tableView.reloadData()
        }
        view.backgroundColor = Theme.accent
        
        plusButton.makeFloatingActionButton()
        
        directions.text = "Tap this button to add a slideshow"
        directions.textColor = UIColor.black
        directions.font = UIFont(name: Theme.mainFontName, size: 15)
        directions.textAlignment = .center
        
//        let originalTransform = directions.transform
//        let distanceTransform = originalTransform.translatedBy(x: 0.0, y: plusButton.frame.origin.y - directions.frame.origin.y - 120)
//        
//        UIView.animate(withDuration: 1.0,
//                       delay: 1.0,
//                       usingSpringWithDamping: 0.7,
//                       initialSpringVelocity: 0.5,
//                       options: .curveEaseIn,
//                       animations: {
//                            self.directions.transform = distanceTransform
//        }) { (animationFinished: Bool) in
//            if animationFinished {
//
//            }
//        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // User signed in...
            // Perform any operations on signed in user here.
            _ = user.userID                  // For client-side use only!
            _ = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            _ = user.profile.givenName
            _ = user.profile.familyName
            _ = user.profile.email
            // ...
            if let name = fullName {
                directions.text = "User: \(name) signed in to Google."
            }
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
        let memoirCount = MemoirData.memoirData.count
        if  memoirCount >= 1 {
            tableView.scrollToRow(at: IndexPath(row: memoirCount - 1, section: 0),
                                  at: .middle,
                                  animated: true)
            directions.text = "Swipe your memoir right for options"
        }
        
        if memoirCount == 1 {
            // design a UIView in editor, with images
        }
    }
    
    func uploadFile(memoir: Memoir) {
        MemoirFunctions.uploadToYouTube(memoir: memoir,
                                        callback:
            { (success) in
                if success {
                    if memoir.onYoutube != nil {
                        MemoirFunctions.saveMemoirsToFile()
                        self.directions.text = "Success! Video uploaded to your YouTube channel"
                    } else {
                        self.directions.text = "Error: Error code - 1, Exceeded daily upload quota"
                    }
                } else {
                    self.directions.text = "Error! Video upload unsuccessful"
                }
        })
    }

}
