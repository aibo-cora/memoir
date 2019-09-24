//
//  TestRecordButton.swift
//  Memoir
//
//  Created by Yura on 8/16/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class TestRecordButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    let animationLayer = CALayer()
    
    func setup() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = frame.height / 2
    }
}
