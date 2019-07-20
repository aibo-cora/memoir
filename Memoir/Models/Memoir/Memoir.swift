//
//  Memoir.swift
//  Memoir
//
//  Created by Yura on 6/29/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import Foundation

class Memoir {
    var title: String
    let memoirID: UUID
    
    init(title: String) {
        self.title = title
        self.memoirID = UUID()
    }
}
