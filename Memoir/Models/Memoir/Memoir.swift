//
//  Memoir.swift
//  Memoir
//
//  Created by Yura on 6/29/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class Memoir {
    var image: UIImage?
    var title: String?
    let memoirID: UUID
    let timeCreated: Date
    var slideShowImages: [UIImage]!
    var filePath: URL?
    
    init(title: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.memoirID = UUID()
        self.image = image
        self.timeCreated = Date()
    }
}
