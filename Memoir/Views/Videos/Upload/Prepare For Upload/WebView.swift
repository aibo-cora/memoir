//
//  webView.swift
//  Memoir
//
//  Created by Yura on 2/7/21.
//  Copyright © 2021 Symbiosis. All rights reserved.
//
import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView  {
        guard let url = URL(string: self.url) else {
            return WKWebView()
        }
        
        let webView = WKWebView()
        
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext <WebView> ) {
        
    }
    
}

#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(url: "https://support.google.com/youtube/answer/157177")
    }
}
#endif
