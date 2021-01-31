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
    @State private var favoriteColor = 0
        var colors = ["Red", "Green", "Blue"]
    
    var body: some View {
        VStack {
            Text("      You are about to upload a video to YouTube, please provide a title, description and privacy setting.")
                .font(.headline)
                .padding()
            //Spacer()
            HStack {
                Text("Title:")
                    .padding()
                    .font(.subheadline)
                Spacer()
                
                TextField("You won't believe what I just saw...", text: $textBindingManager.text)
            }
            //Spacer()
            HStack {
                Text("Description:")
                    .padding()
                    .font(.subheadline)
                Spacer()
                // UITextView
            }
            Spacer()
            VStack {
                Text("Privacy setting")
                    .font(.subheadline)
                Picker(selection: $favoriteColor, label: Text("Privacy setting")) {
                    Text("Public").tag(0)
                    Text("Private").tag(1)
                    Text("Unlisted").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            HStack {
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                    Text("Upload")
                        .foregroundColor(.red)
                }
                .padding()
            }
        }
        
        
    }
}

struct ConfigureUploadUI_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureUploadUI()
    }
}
