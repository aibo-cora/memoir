//
//  PhotoCollectionViewCell.swift
//  Memoir
//
//  Created by Yura on 8/29/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifer = "PhotoCollectionViewCell"
    let featuredPhotoView = UIImageView()
    let contentContainer = UIView()
    let titleLabel = UILabel()
    
    var title: String? {
      didSet {
        configure()
      }
    }

    var thumbnailImage: UIImage? {
      didSet {
        configure()
      }
    }

    override init(frame: CGRect) {
      super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
}

extension AssetCollectionViewCell {
    func configure() {
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
        
        clipsToBounds = true
      
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(featuredPhotoView)
        contentView.addSubview(contentContainer)

        featuredPhotoView.translatesAutoresizingMaskIntoConstraints = false
        if let image = thumbnailImage {
            featuredPhotoView.image = image
            featuredPhotoView.contentMode = .scaleAspectFill
        }
        featuredPhotoView.layer.cornerRadius = 4
        featuredPhotoView.clipsToBounds = true
        contentContainer.addSubview(featuredPhotoView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        titleLabel.adjustsFontForContentSizeCategory = true
        contentContainer.addSubview(titleLabel)

        let spacing = CGFloat(10)
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            featuredPhotoView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            featuredPhotoView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            featuredPhotoView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: featuredPhotoView.bottomAnchor, constant: spacing),
            titleLabel.leadingAnchor.constraint(equalTo: featuredPhotoView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: featuredPhotoView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
}
