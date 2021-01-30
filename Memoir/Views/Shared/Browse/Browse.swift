//
//  Browse.swift
//  Memoir
//
//  Created by Yura on 1/10/21.
//  Copyright © 2021 Symbiosis. All rights reserved.
//

import UIKit

class Browse: UIViewController {
    
    enum Section: String, CaseIterable, Hashable {
      case media = "Memories"
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CustomAsset>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CustomAsset>
    
    var browseCollectionView: UICollectionView! = nil
    var dataSource: DataSource! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureCollectionView()
        configureDataSource()
        snapshotForCurrentState()
    }

    fileprivate func snapshotForCurrentState() {
        
    }
}

// MARK: - Collection View Setup
extension Browse {
    
    fileprivate func configureDataSource() {
        
        dataSource = DataSource(collectionView: browseCollectionView) {
            (collectionView, indexPath, CustomAsset) -> UICollectionViewCell? in
            
            let section = Section.allCases[indexPath.section]
            switch section {
            case .media:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AssetCollectionViewCell.reuseIdentifer,
                    for: indexPath) as? AssetCollectionViewCell else { fatalError("Could not create new cell") }
                
                if let thumbnail = CustomAsset.memory.thumbnail {
                    if let image = thumbnail.image {
                        cell.thumbnailImage = UIImage(data: image)
                    }
                }
                return cell
            }
        }
    }
    
    fileprivate func configureCollectionView() {
        browseCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        
        view.addSubview(browseCollectionView)
        browseCollectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        browseCollectionView.backgroundColor = .systemBackground
        browseCollectionView.delegate = self
        // collectionView.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: AssetCollectionViewCell.reuseIdentifer)
    }
    
    fileprivate func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
          (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
          
          _ = layoutEnvironment.container.effectiveContentSize.width > 500

          let sectionLayoutKind = Section.allCases[sectionIndex]
          
          switch sectionLayoutKind {
          case .media:
              return self.generateSectionLayout()
          }
        }
        
        return layout
    }
    
    fileprivate func generateSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1/4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: fullPhotoItem, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}

// MARK: - Collection View Delegate
extension Browse: UICollectionViewDelegate {
    
}
