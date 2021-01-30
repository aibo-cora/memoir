//
//  CanvasViewController.swift
//  Memoir
//
//  Created by Yura on 8/29/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class PhotoAssetsViewController: UIViewController {
    
    @IBOutlet weak var videoButton: UIBarButtonItem!
    
    enum Section: String, CaseIterable, Hashable {
      case movieComponents = "Movie Components"
      case media = "Assets"
    }
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var assets = [CustomAsset]()
    var searchAssets = [CustomAsset]()
    var movieComponents = [CustomAsset]()
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    // MARK: - Value Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CustomAsset>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CustomAsset>
    
    private var searchController = UISearchController(searchResultsController: nil)
    var assetsCollectionView: UICollectionView! = nil
    var dataSource: DataSource! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // add observer
        NotificationCenter.default.addObserver(self, selector: #selector(fetchMemories(_:)), name: .CoreDataAddItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchMemories(_:)), name: .CoreDataUpdate, object: nil)
        // Do any additional setup after loading the view.
        if let tabBarController = tabBarController {
            if let selected = tabBarController.selectedViewController {
                if let title = selected.title {
                    navigationItem.title = title
                    
                    switch title {
                    case "Videos":
                        tabBarController.tabBar.selectedItem?.badgeValue = "0"
                    default:
                        break
                    }
                }
            }
        }
        
        configureSearchController()
        configureCollectionView()
        configureDataSource()
        // Fetch data from CoreData and populate view
        fetchMemories(Notification(name: .CoreDataFetchItems))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        feedbackGenerator.prepare()
        
        if let tabBarController = tabBarController {
            if let selected = tabBarController.selectedViewController {
                if let title = selected.title {
                    switch title {
                    case "Videos":
                        tabBarController.tabBar.selectedItem?.badgeValue = "0"
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @objc func fetchMemories(_ notification: Notification) {
        var result = [Memory]()
        assets.removeAll()
        
        if let appDelegate =
          UIApplication.shared.delegate as? AppDelegate {
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<Memory>(entityName: "Memory")
            let sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
            var predicate = NSPredicate()
            
            if let title = navigationItem.title {
                switch title {
                case "Photos":
                    predicate = NSPredicate(format: "mediaType == %@", "image")
                case "Videos":
                    predicate = NSPredicate(format: "mediaType == %@", "video")
                default:
                    break
                }
            }
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                result = try managedObjectContext.fetch(fetchRequest)
            } catch {
                
            }
        }
        switch notification.name {
        case .CoreDataFetchItems:
            movieComponents.removeAll()
        default:
            break
        }
        
        for memory in result {
            assets.append(CustomAsset(memory: memory))
        }
        snapshotForCurrentState()
    }
    
    // MARK: Actions
    @IBAction func renderVideo(_ sender: UIBarButtonItem) {
        videoButton.isEnabled = false
        feedbackGenerator.prepare()
        
        if let tabController = tabBarController {
            if let tabBarItems = tabController.tabBar.items {
                for item in tabBarItems {
                    if let title = item.title {
                        if title == "Videos" {
                            if let badgeValue = item.badgeValue {
                                if let value = Int(badgeValue) {
                                    item.badgeValue = "\(value + 1)"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if let collectionView = assetsCollectionView {
            for count in 0..<collectionView.numberOfItems(inSection: 0) - 1 {
                if let _ = collectionView.cellForItem(at: IndexPath(item: count, section: 0)) {
                    // animate all cell to middle, then drop and render
                }
            }
        }
        
        movieComponents.removeAll()
        snapshotForCurrentState()
        feedbackGenerator.impactOccurred()
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension PhotoAssetsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchTags = searchController.searchBar.text
        searchAssets.removeAll()
        
        if var searchText = searchTags {
            searchText = searchText.lowercased().filter { $0 != "#" }
            let separate = searchText.components(separatedBy: ",")
            
            for searchTag in separate {
                let filteredSearchTag = searchTag.filter { !$0.isWhitespace }
                
                for asset in assets {
                    if let memoryTags = asset.memory.tags {
                        let tags = memoryTags.components(separatedBy: ",")
                        
                        if tags.contains(filteredSearchTag) {
                            searchAssets.append(asset)
                        }
                    }
                }
            }
        }
        
        searchAssets.sort { $0.memory.rating > $1.memory.rating }
        snapshotForCurrentState()
    }
    
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search media by #'s"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

 // MARK: - Configure Collection View
extension PhotoAssetsViewController {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: AssetCollectionViewCell.reuseIdentifer)
        collectionView.register(MovieComponentCollectionViewCell.self, forCellWithReuseIdentifier: MovieComponentCollectionViewCell.reuseIdentifer)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: PhotoAssetsViewController.sectionHeaderElementKind, withReuseIdentifier: HeaderView.reuseIdentifier)
        
        assetsCollectionView = collectionView
    }
    
    func configureDataSource() {
        
        dataSource = DataSource(collectionView: assetsCollectionView) { (collectionView, indexPath, CustomAsset) -> UICollectionViewCell? in
            
            let section = Section.allCases[indexPath.section]
            switch section {
            case .media:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AssetCollectionViewCell.reuseIdentifer,
                    for: indexPath) as? AssetCollectionViewCell else { fatalError("Could not create new cell") }
                
                if let media = CustomAsset.memory.media {
                   cell.thumbnailImage = UIImage(data: media)
                }
                
                if let title = CustomAsset.memory.title {
                    cell.title = title
                }
                return cell
            case .movieComponents:
                guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieComponentCollectionViewCell.reuseIdentifer,
                for: indexPath) as? MovieComponentCollectionViewCell else { fatalError("Could not create new cell") }
                
                if let media = CustomAsset.memory.media {
                   cell.thumbnailImage = UIImage(data: media)
                }
                
                if let title = CustomAsset.memory.title {
                    cell.title = title
                }
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in

        guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else {
                fatalError("Cannot create header view")
            }

        supplementaryView.label.text = Section.allCases[indexPath.section].rawValue
            
        return supplementaryView
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
      let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        _ = layoutEnvironment.container.effectiveContentSize.width > 500

        let sectionLayoutKind = Section.allCases[sectionIndex]
        
        switch sectionLayoutKind {
        case .media:
            return self.generateAssetsLayout()
        case .movieComponents:
            return self.generateMovieComponentLayout()
        }
      }
      return layout
    }
    
    func generateAssetsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1/4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: fullPhotoItem, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: PhotoAssetsViewController.sectionHeaderElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func generateMovieComponentLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
          widthDimension: .absolute(150),
          heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: PhotoAssetsViewController.sectionHeaderElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    func snapshotForCurrentState() {
        var snapshot = Snapshot()
        
        snapshot.appendSections([Section.movieComponents])
        snapshot.appendItems(movieComponents, toSection: Section.movieComponents)
        
        snapshot.appendSections([Section.media])
        if searchAssets.count > 0 {
            snapshot.appendItems(searchAssets, toSection: Section.media)
        } else {
            snapshot.appendItems(assets, toSection: Section.media)
        }
        
        if let datasource = dataSource {
            datasource.apply(snapshot, animatingDifferences: true) {
                datasource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
}

// MARK: UICollectionViewDelegate
extension PhotoAssetsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        switch indexPath.section {
        case 0:
            let menuConfig = UIContextMenuConfiguration(identifier: "Movie Component Menu" as NSCopying, previewProvider: nil) { (menuElement) -> UIMenu? in
                let delete = UIAction(title: "Remove", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { (action) in
                    self.movieComponents.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.snapshotForCurrentState()
                    }
                    
                    
                    if self.movieComponents.isEmpty {
                        self.videoButton.isEnabled = false
                    }
                }
                
                let menu = UIMenu(title: "", image: nil, identifier: .none, options: .displayInline, children: [delete])
                return menu
            }
            return menuConfig
        case 1:
            let menuConfig = UIContextMenuConfiguration(identifier: "Asset Menu" as NSCopying, previewProvider: { () -> UIViewController? in
                
                guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                return MemoryPreviewViewController(memory: selectedAsset.memory)
                
            }) { (menuElement) -> UIMenu? in
                let delete = UIAction(title: "Remove", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { (action) in
                    
                    if let delegate = self.appDelegate {
                        let managedObjectContext = delegate.persistentContainer.viewContext
                        
                        managedObjectContext.delete(self.assets.remove(at: indexPath.row).memory)
                        
                        do {
                            try managedObjectContext.save()
                        } catch let error {
                            print("Could not save into Core Data. Error: \(error), \(error.localizedDescription)")
                        }
                        print("Memory removed from Core Data.")
                    }
                    DispatchQueue.main.async {
                        self.snapshotForCurrentState()
                    }
                    
                }
                let addMovieComponent = UIAction(title: "Add movie component", image: nil, identifier: nil, discoverabilityTitle: nil) { (action) in
                    
                    guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else {
                        return
                    }
                    self.videoButton.isEnabled = true
                    
                    DispatchQueue.main.async {
                        self.movieComponents.append(CustomAsset(memory: selectedAsset.memory))
                        self.snapshotForCurrentState()
                    }
                }
                let menu = UIMenu(title: "", image: nil, identifier: .none, options: .displayInline, children: [addMovieComponent,delete])
                return menu
            }
            return menuConfig
        default:
            return nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            break
        case 1:
            let storyboard = UIStoryboard(name: String(describing: MemoirViewController.self), bundle: nil)
            if let detail = storyboard.instantiateViewController(withIdentifier: "AssetDetailID") as? AssetDetailViewController {
                guard let selectedAsset = dataSource.itemIdentifier(for: indexPath) else {
                    return
                }
                
                detail.hidesBottomBarWhenPushed = true
                detail.memory = selectedAsset.memory
                detail.memoryIndex = indexPath.row
                
                feedbackGenerator.impactOccurred()
                if let navigation = navigationController {
                    navigation.pushViewController(detail, animated: true)
                }
            }
        default:
            break
        }
    }
}

// MARK: UIContextMenuInteractionDelegate
