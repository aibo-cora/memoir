//
//  showPhotoLibraryButton.swift
//  Memoir
//
//  Created by Yura on 7/25/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class showPhotoLibraryButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
 //       imageView?.image = UIImage(named: "Resources/images.xcassets/imageButton.50.imageset/imageButton.50.png")
 //       backgroundColor = Theme.tint
     
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 10
    }

}
