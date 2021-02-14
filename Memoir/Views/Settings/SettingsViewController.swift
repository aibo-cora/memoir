//
//  SettingsViewController.swift
//  Memoir
//
//  Created by Yura on 8/22/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import GoogleSignIn

class SettingsViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let googleSectionMembers = ["Manage security settings",
                                "Google Privacy Policy",
                                "YouTube Terms of Service"]
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                 withError error: Error!) {
        
        if let error = error {
           if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
             print("The user has not signed in before or they have since signed out.")
           }
            if (error as NSError).code == GIDSignInErrorCode.canceled.rawValue {
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                    if let accessory = cell.accessoryView as? UISwitch {
                        accessory.isOn = false
                    }
                }
                } else {
                    print("\(error.localizedDescription)")
                }
           return
        }
     // Perform any operations on signed in user here.
        _ = user.userID                  // For client-side use only!
        _ = user.authentication.idToken // Safe to send to the server
        _ = user.profile.name
        _ = user.profile.givenName
        _ = user.profile.familyName
        _ = user.profile.email
        updateTitle()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    /// This function gets called when the view appears and "Login" switch toggles
    func updateTitle() {
        if let navigation = self.navigationController {
            if let user = GIDSignIn.sharedInstance()?.currentUser {
                if let name = user.profile.name {
                    navigation.navigationBar.topItem?.title = "Logged in as: \(name)"
                }
            } else {
                navigation.navigationBar.topItem?.title = "Logged off."
            }
        }
    }
}
