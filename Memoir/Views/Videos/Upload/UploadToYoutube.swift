//
//  UploadToYoutube.swift
//  Memoir
//
//  Created by Yura on 9/10/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import Alamofire
import SwiftyJSON
import GoogleSignIn

extension VideoAssetViewController {
    
    func retreiveVideoURL(videoID: String) -> URL? {
        if videoID != "" {
            let youTubeLink = "https://www.youtube.com/watch?v=" + "\(videoID)"
            let videoURL = URL(string: youTubeLink)
            
            return videoURL
        } else {
            return nil
        }
    }
    
    func uploadToYouTube(filePath: URL, videoStory: String?, callback: @escaping (Bool, URL?) -> Void)
    {
        print("Uploading to YouTube...")
        let token = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(token ?? "No token")"]
        // check scope
        // .the credential that google "auto-generated" for me does not
        // use the /youtube.upload scope
        var storyToUpload = "No description"
        if let story = videoStory {
            storyToUpload = story
        }
        AF.upload(
            multipartFormData: { (multipartFormData) in
                multipartFormData.append("{'snippet':{'title' : 'My memory.','description': '\(storyToUpload)'}}".data(using: String.Encoding.utf8, allowLossyConversion: false)!,
                                         withName: "snippet",
                                         mimeType: "application/json")
                multipartFormData.append(filePath,
                                         withName: "video",
                                         fileName: "renderedVideo.mp4",
                                         mimeType: "application/octet-stream")
        },
            to: "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet",
            //    to: "https://www.googleapis.com/upload/youtube/v3/videos",
            method: .post,
            headers: headers).responseJSON(completionHandler: { (response) in
                switch response.result {
                case let .success(value):
                    let videoJSON = JSON(value) // convert Any to JSON
                    print(value)
                    let videoID = videoJSON["id"].stringValue
                    
                    if let videoURL =  self.retreiveVideoURL(videoID: videoID) {
                        print("Uploaded to YouTube @ \(videoURL)")
                        callback(true, videoURL)
                    }
                case .failure (let error):
                    print("Upload error: \(error.localizedDescription)")
                    callback(false, nil)
                }
            })
    }
}
