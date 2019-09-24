//
//  RecordAudioTableViewCell.swift
//  Memoir
//
//  Created by Yura on 8/22/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class RecordAudioTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {
        backgroundColor = UIColor.black
        textLabel?.textColor = UIColor.white
        
        accessoryType = .disclosureIndicator
    }
}
