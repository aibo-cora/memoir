//
//  Extension.Settings.swift
//  Memoir
//
//  Created by Yura on 8/22/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import GoogleSignIn

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Log in"
            let switchControl = UISwitch(frame: CGRect.zero)
            
            if GIDSignIn.sharedInstance()?.currentUser == nil {
                switchControl.isOn = false
            } else {
                switchControl.isOn = true
            }
            
            switchControl.addTarget(self, action: #selector(LoginSwitch(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
            updateTitle()
        default:
            break
        }
        return cell
    }
    
    @objc func LoginSwitch(_ sender: UISwitch!) {
        print("Login switch...")
        if sender.isOn {
            GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.upload")
            GIDSignIn.sharedInstance().signIn()
        } else {
            GIDSignIn.sharedInstance()?.signOut()
        }
        updateTitle()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Gain access to your Google account."
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Upload videos to your YouTube channel for storage or sharing."
        default:
            return ""
        }
    }
    
}
