//
//  UIButton.swift
//  Memoir
//
//  Created by Yura on 7/20/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func makeFloatingActionButton() {
        backgroundColor = Theme.tint
        layer.cornerRadius = frame.height / 2
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}
