//
//  Memoir.swift
//  Memoir
//
//  Created by Yura on 6/29/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import Foundation

class Memoir {
    var title: String!
    var memoirID: String!
    
    init(title: String) {
        self.title = title
        self.memoirID = UUID().uuidString
    }
}
