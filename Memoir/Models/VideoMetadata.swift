//
//  VideoMetadata.swift
//  Memoir
//
//  Created by Yura on 2/7/21.
//  Copyright © 2021 Symbiosis. All rights reserved.
//

import Foundation

enum PrivacySetting: Int {
    case privateSetting, publicSetting, unlistedSetting
}

struct VideoMetadata {
    let title: String
    let description: String
    
    let privacySetting: PrivacySetting
}
