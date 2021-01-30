//
//  CGSize.swift
//  Memoir
//
//  Created by Yura on 9/19/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import Foundation

extension CGSize {
    func resizeFill(toSize: CGSize) -> CGSize {

        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
        return CGSize(width: (self.width / scale), height: (self.height / scale))

    }
}
