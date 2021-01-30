//
//  Notification.swift
//  Memoir
//
//  Created by Yura on 8/30/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import Foundation
import NotificationCenter

extension Notification.Name {
    static let CoreDataFetchItems = Notification.Name("CoreDataFetchItems")
    static let CoreDataAddItem = Notification.Name("CoreDataAddItem")
    static let CoreDataUpdate = Notification.Name("CoreDataUpdate")
    static let CoreDataFetchVideoAssets = Notification.Name("CoreDataFetchVideoAssets")
    
    static let AssetDeleted = Notification.Name("AssetDeleted")
}
