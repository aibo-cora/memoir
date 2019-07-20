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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.addShadowRoundedCorners()
        cardView.backgroundColor = Theme.background
    }
    
    func setup(memoir: Memoir) {
        titleLabel.font = UIFont(name: Theme.mainFontName, size: 30)
        titleLabel.text = memoir.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
