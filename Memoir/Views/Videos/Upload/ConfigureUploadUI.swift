//
//  ConfigureUploadUI.swift
//  Memoir
//
//  Created by Yura on 1/30/21.
//  Copyright © 2021 Symbiosis. All rights reserved.
//

import SwiftUI

class TextBindingManager: ObservableObject {
    @Published var text = "" {
        didSet {
            if text.count > characterLimit && oldValue.count <= characterLimit {
                text = oldValue
            }
        }
    }
    let characterLimit: Int

    init(limit: Int = 100){
        characterLimit = limit
    }
}

struct ConfigureUploadUI: View {
    @ObservedObject var textBindingManager = TextBindingManager()
    @State private var privacySetting = 0
    @State private var showUpload = false
    @State private var showWebView = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("      You are about to upload a video to YouTube, please provide a title, description and privacy setting.")
                    .font(.subheadline)
                    .padding()
                VStack {
                    Button(action: {
                        showWebView.toggle()
                    }, label: {
                        Text("Privacy setting")
                    })
                    .sheet(isPresented: $showWebView, onDismiss: didDismiss, content: {
                        WebView(url: "https://support.google.com/youtube/answer/157177")
                    })
                    Picker(selection: $privacySetting, label: Text("Privacy setting")) {
                        Text("Public").tag(0)
                        Text("Private").tag(1)
                        Text("Unlisted").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                
                HStack {
                    Text("Title:")
                        .padding()
                        .font(.subheadline)
                    Spacer()
                    
                    TextField("You won't believe what I just saw...", text: $textBindingManager.text)
                        .padding()
                }
                
                HStack {
                    Text("Description:")
                        .padding()
                        .font(.subheadline)
                    Spacer()
                    // UITextView
                }
                Spacer()
            }
            .navigationBarItems(trailing: Button("Upload") {
                print("Upload button pressed.")
            }.disabled(!showUpload))
        }
    }
    
    func didDismiss() {
        
    }
}

struct ConfigureUploadUI_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureUploadUI()
    }
}
