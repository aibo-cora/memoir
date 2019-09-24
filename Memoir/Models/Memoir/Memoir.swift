//
//  Memoir.swift
//  Memoir
//
//  Created by Yura on 6/29/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class Memoir: NSObject, NSCoding {
    
    static let ArchiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("memoirs")
    
    enum Keys: String {
        case title = "Title"
        case version = "Version"
        case memoirID = "UUID"
        case image = "Image"
        case time = "Time"
        case onYouTube = "onYouTube"
        case filePath = "FilePath"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Keys.title.rawValue)
        aCoder.encode(version, forKey: Keys.version.rawValue)
        aCoder.encode(memoirID, forKey: Keys.memoirID.rawValue)
        aCoder.encode(image, forKey: Keys.image.rawValue)
 //       aCoder.encode(timeCreated, forKey: Keys.time.rawValue)
        aCoder.encode(onYoutube, forKey: Keys.onYouTube.rawValue)
        aCoder.encode(filePath, forKey: Keys.filePath.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObject(forKey: Keys.title.rawValue) as? String
        let version = aDecoder.decodeInt32(forKey: Keys.version.rawValue)
        let memoirID = aDecoder.decodeObject(forKey: Keys.memoirID.rawValue) as! UUID
        let image = aDecoder.decodeObject(forKey: Keys.image.rawValue) as? UIImage
        let uploaded = aDecoder.decodeObject(forKey: Keys.onYouTube.rawValue) as? String
 //       let timeCreated = aDecoder.decodeObject(forKey: Keys.time.rawValue) as! Date
        let filePath = aDecoder.decodeObject(forKey: Keys.filePath.rawValue) as? URL

        self.init(title: title,
                  image: image,
                  filePathURL: filePath,
                  version: version,
                  memoirID: memoirID,
                  onYoutube: uploaded)
    }
    
    var image: UIImage?
    var title: String?
    let memoirID: UUID
    let timeCreated: Date
    var slideShowImages: [UIImage]!
    var filePath: URL?
    var filePathWithNewRecording: URL?
    var onYoutube: String?
    var version: Int32
    
    init(title: String? = nil, image: UIImage? = nil, filePathURL: URL? = nil,
         version: Int32, memoirID: UUID, onYoutube: String? = nil)
    {
        self.title = title
        self.memoirID = memoirID
        self.image = image
        self.timeCreated = Date()
        self.onYoutube = onYoutube
        self.version = version
        self.filePath = filePathURL
    }
}
