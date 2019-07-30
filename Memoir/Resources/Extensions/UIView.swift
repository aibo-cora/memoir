//
//  UIViewExtension.swift
//  Memoir
//
//  Created by Yura on 7/17/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addShadowRoundedCorners() {
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 10
    }
    
    func addDeeperShadowRoundedCorners() {
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 20
    }
}
