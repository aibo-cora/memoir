//
//  ImageViewTableViewCell.swift
//  Memoir
//
//  Created by Yura on 7/24/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class ImageViewTableViewCell: UITableViewCell {
    @IBOutlet weak var imageNumberLabel: UILabel!
    @IBOutlet weak var imageViewCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(at index: Int, using image: UIImage) {
        // setup outlets
        // set datasource and delegate
        imageNumberLabel.text = "\(index)"
        imageViewCell.image = image
    }

}
