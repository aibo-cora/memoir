//
//  AssetCell.swift
//  Memoir
//
//  Created by Yura on 8/25/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit

class AssetCell: UICollectionViewCell {
    @IBOutlet weak var assetImageView: UIImageView!
    
    var checkmarkView: SSCheckMark!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkmarkView = SSCheckMark(frame: CGRect(x: 20, y: 20, width: 35, height: 35))
        checkmarkView.backgroundColor = UIColor.clear

        contentMode = .scaleAspectFill
        addSubview(checkmarkView)
    }
    
    func setup(using image: UIImage) {
        assetImageView.image = image
        assetImageView.contentMode = .scaleAspectFill
        
        layer.cornerRadius = 20
        clipsToBounds = true
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.gray.cgColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                layer.borderWidth = 5.0
                layer.borderColor = UIColor.orange.cgColor
            } else {
                layer.borderWidth = 2.0
                layer.borderColor = UIColor.gray.cgColor
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                checkmarkView.checked = true
            } else {
                layer.borderWidth = 2.0
                layer.borderColor = UIColor.gray.cgColor
                checkmarkView.checked = false
            }
        }
    }
}
