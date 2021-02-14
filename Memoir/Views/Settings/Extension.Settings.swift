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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        default:
            return googleSectionMembers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Log in"
            cell.textLabel?.textColor = UIColor.black
            
            let switchControl = UISwitch(frame: CGRect.zero)
            
            if GIDSignIn.sharedInstance()?.currentUser == nil {
                switchControl.isOn = false
            } else {
                switchControl.isOn = true
            }
            
            switchControl.addTarget(self, action: #selector(LoginSwitch(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
            updateTitle()
        case 1:
            cell.textLabel?.text = "Life Memories Privacy Policy"
            cell.textLabel?.textColor = UIColor(red: 51/255, green: 102/255, blue: 187/255, alpha: 1.0)
        case 2:
            cell.textLabel?.text = googleSectionMembers[indexPath.row]
            cell.textLabel?.textColor = UIColor(red: 51/255, green: 102/255, blue: 187/255, alpha: 1.0)
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
        case 1:
            return "Our policies."
        case 2:
            return "Google's and YouTube's policies."
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Upload videos to your YouTube channel for storage or sharing."
        case 1:
            return "Read what we do with your personal information."
        case 2:
            return "Read what Google and YouTube does with your personal infomation."
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lookupPrivacyInfo = LookUpView()
        
        switch indexPath.section {
        case 1:
            lookupPrivacyInfo.url = URL(string: "https://www.symbiosis.business/life-memories-privacy-policy")
        default:
            switch indexPath.row {
            case 0:
                lookupPrivacyInfo.url = URL(string: "https://support.google.com/a/answer/2537800")
            case 1:
                lookupPrivacyInfo.url = URL(string: "https://policies.google.com/privacy")
            case 2:
                lookupPrivacyInfo.url = URL(string: "https://www.youtube.com/static?template=terms")
            default:
                break
            }
        }
        
        present(lookupPrivacyInfo, animated: true, completion: nil)
    }
}
