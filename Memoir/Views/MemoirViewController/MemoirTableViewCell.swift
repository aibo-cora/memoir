//
//  MemoirTableViewCell.swift
//  Memoir
//
//  Created by Yura on 7/16/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class MemoirTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.addShadowRoundedCorners()
        cardView.backgroundColor = Theme.background
        
        cellImageView.layer.cornerRadius = cardView.layer.cornerRadius
    }
    
    func setup(memoir: Memoir) {
        cellImageView.image = memoir.image
        
        titleLabel.font = UIFont(name: Theme.mainFontName, size: 30)
        titleLabel.text = memoir.title
        titleLabel.textColor = Theme.tint
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
