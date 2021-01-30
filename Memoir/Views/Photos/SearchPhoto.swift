//
//  SpeechSearch.swift
//  Memoir
//
//  Created by Yura on 9/25/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit

extension PhotoAssetsViewController: UISearchBarDelegate {
    /// Configure a custom UIView to display tips how to refine and make search more efficient.
    /// - Parameter searchBar: Question mark tapped inside the search bar
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        let displaySearchTips = SearchQuestionView(frame: CGRect(origin: .zero, size: .zero))
        view.addSubview(visualEffectView)
        visualEffectView.frame = CGRect(origin: .zero, size: view.frame.size)
        visualEffectView.contentView.addSubview(displaySearchTips)
        
        displaySearchTips.translatesAutoresizingMaskIntoConstraints = false
        
        displaySearchTips.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 4).isActive = true
        displaySearchTips.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        displaySearchTips.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        displaySearchTips.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 4).isActive = true
        
        let tapToDismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeSearchTipsView))
        visualEffectView.addGestureRecognizer(tapToDismissRecognizer)
    }
    
    @objc func removeSearchTipsView() {
        for subview in view.subviews {
            if let visualEffectView = subview as? UIVisualEffectView {
                visualEffectView.removeFromSuperview()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchMode = false
    }
}

