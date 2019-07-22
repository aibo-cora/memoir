//
//  popUpChoiceButton.swift
//  Memoir
//
//  Created by Yura on 7/20/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class popUpChoiceButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = Theme.tint
        layer.cornerRadius = frame.height / 2
        setTitleColor(UIColor.white,
                      for: .normal)
    }

}
