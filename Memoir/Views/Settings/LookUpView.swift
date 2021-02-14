//
//  WebView.swift
//  Memoir
//
//  Created by Yura on 2/14/21.
//  Copyright © 2021 Symbiosis. All rights reserved.
//

import UIKit
import WebKit

class LookUpView: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var url: URL?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let myURL = url {
            let myRequest = URLRequest(url: myURL)
            
            webView.load(myRequest)
        }
    }
}
