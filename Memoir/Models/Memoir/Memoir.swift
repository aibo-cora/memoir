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
    var title: String
    let memoirID: UUID
    
    init(title: String, image: UIImage? = nil) {
        self.title = title
        self.memoirID = UUID()
        self.image = image
    }
}
