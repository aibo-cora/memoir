//
//  MovieComponentCollectionViewCell.swift
//  Memoir
//
//  Created by Yura on 9/6/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit

class MovieComponentCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifer = "MovieComponentCollectionViewCell"
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
        }

        required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
        }
    }

extension MovieComponentCollectionViewCell {
    func configure() {
        clipsToBounds = true
        layer.cornerRadius = 20
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.gray.cgColor
    
      contentView.addSubview(featuredPhotoView)

      featuredPhotoView.translatesAutoresizingMaskIntoConstraints = false
      if let image = thumbnailImage {
        featuredPhotoView.image = image
        featuredPhotoView.contentMode = .scaleAspectFill
      }
      featuredPhotoView.layer.cornerRadius = 4
      featuredPhotoView.clipsToBounds = true

      NSLayoutConstraint.activate([
        featuredPhotoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        featuredPhotoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        featuredPhotoView.topAnchor.constraint(equalTo: contentView.topAnchor),
        featuredPhotoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
      ])
    }
}
