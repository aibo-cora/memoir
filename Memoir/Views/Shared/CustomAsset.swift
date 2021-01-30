//
//  MovieComponent.swift
//  Memoir
//
//  Created by Yura on 9/6/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import Foundation

class CustomAsset: Hashable {
    let identifier = UUID()
    let memory: Memory
    var state = AssetExportState.beingExported
    
    static func == (lhs: CustomAsset, rhs: CustomAsset) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }
    
    init(memory: Memory) {
        self.memory = memory
    }
}
