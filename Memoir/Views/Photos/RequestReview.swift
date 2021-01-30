//
//  File.swift
//  Memoir
//
//  Created by Yura on 9/8/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import StoreKit

extension PhotoAssetsViewController {
    func shouldDisplayRequestReview() {
        // If the count has not yet been stored, this will return 0
        var count = UserDefaults.standard.integer(forKey: UDKeys.processCompletedCountKey)
        count += 1
        UserDefaults.standard.set(count, forKey: UDKeys.processCompletedCountKey)
        
        // Get the current bundle version for the app
        let infoDictionaryKey = kCFBundleVersionKey as String
        
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else {
                fatalError("Expected to find a bundle version in the info dictionary")
        }
        
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UDKeys.lastVersionPromptedForReviewKey)
        
        // Has the process been completed several times and the user has not already been prompted for this version?
        if count >= 4 && currentVersion != lastVersionPromptedForReview {
            let twoSecondsFromNow = DispatchTime.now() + 2.0
            DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
                UserDefaults.standard.set(currentVersion, forKey: UDKeys.lastVersionPromptedForReviewKey)
                self.displayRequestReview()
            }
        }
    }
    
    func displayRequestReview() {
        if #available(iOS 10.3, *) {

            SKStoreReviewController.requestReview()

        } else {
            let appID = "1481139300"
            let urlStr = "https://itunes.apple.com/app/id\(appID)?action=write-review" // (Option 2) Open App Review Page

            guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
