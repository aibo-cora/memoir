//
//  GoogleExtension.swift
//  Memoir
//
//  Created by Yura on 7/30/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import Foundation
import GoogleSignIn

extension MemoirViewController: GIDSignInDelegate,
                                GIDSignInUIDelegate {
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
            print("User: \(String(describing: fullName)) signed in to Google.")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        GIDSignIn.sharedInstance()?.signOut()
    }
}
