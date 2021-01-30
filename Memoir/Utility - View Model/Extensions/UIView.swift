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

extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
}

extension Double {
    var toTimeString: String {
        let seconds: Int = Int(self.truncatingRemainder(dividingBy: 60.0))
        let minutes: Int = Int(self / 60.0)
        return String(format: "%d:%02d", minutes, seconds)
    }
}
