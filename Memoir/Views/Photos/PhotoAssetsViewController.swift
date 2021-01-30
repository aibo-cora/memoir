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
import GoogleSignIn
import Speech

class PhotoAssetsViewController: UIViewController {
    
    @IBOutlet weak var videoButton: UIBarButtonItem!
    
    enum Section: String, CaseIterable, Hashable {
      case movieComponents = "Movie Components"
      case media = "Memories"
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
    
    var searchController = UISearchController(searchResultsController: nil)
    var searchMode: Bool = false
    
    var assetsCollectionView: UICollectionView! = nil
    var dataSource: DataSource! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldDisplayRequestReview()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController {
            if let createController = destination.topViewController as? CreateMemoirGridController {
                createController.mediaType = "image"
            }
        }
    }
    
    @objc func fetchMemories(_ notification: Notification) {
        DispatchQueue.main.async { [unowned self] in
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
    }
    
    // MARK: Actions
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        configureCamera()
    }
    
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
        
        assetsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        
        if let collectionView = assetsCollectionView {
            for count in 0..<collectionView.numberOfItems(inSection: 0) - 1 {
                if let _ = collectionView.cellForItem(at: IndexPath(item: count, section: 0)) {
                    // animate all cell to middle, then drop and render
                }
            }
        }
        let story = NSMutableAttributedString()
        var components = [UIImage]()
        for component in movieComponents {
            let memory = component.memory
            
            if let thumbnail = memory.thumbnail {
                if let media = thumbnail.image {
                    if let memoryImage = UIImage(data: media) {
                        components.append(memoryImage)
                    }
                }
            }
            
            if let componentStory = memory.attributedStory {
                story.append(componentStory)
                story.append(NSAttributedString(string: "\n\n"))
            }
        }
        var settings = RenderSettings()
        settings.size = CGSize(width: view.frame.width, height: view.frame.height / 2)
        let animator = ImageAnimator(renderSettings: settings, images: components)

        animator.render {
            Utility.createAsset(using: nil, using: settings.outputURL)
            Utility.saveContext(message: "Movie rendered from images, context saved.")
            
            NotificationCenter.default.post(name:.CoreDataFetchVideoAssets, object: nil)
        }
        
        movieComponents.removeAll()
        snapshotForCurrentState()
        feedbackGenerator.impactOccurred()
    }
}

// MARK: - UISearchResultsUpdating, UISearchController Delegate
extension PhotoAssetsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchTags = searchController.searchBar.text
        searchAssets.removeAll()
        
        if var searchText = searchTags {
            searchText = searchText.lowercased()
            searchText = searchText.filter { $0 != "#" }
            searchText = searchText.filter { !$0.isWhitespace }
            let separate = searchText.components(separatedBy: ",")
            
            for searchTag in separate {
                for asset in assets {
                    if let memoryTags = asset.memory.tags {
                        print(memoryTags)
                        let tags = memoryTags.components(separatedBy: ",")
                        
                        if searchTag == "" {
                            
                        } else {
                            if searchTag.contains("+") {
                                let plusSeparate = searchTag.components(separatedBy: "+")
                                var mutual = true
                                for plusWord in plusSeparate {
                                    if plusWord == "" {
                                        mutual = false
                                    }
                                    if tags.contains(plusWord) {
                                        
                                    } else {
                                        mutual = false
                                    }
                                }
                                if mutual {
                                    var assetDisplayed = false
                                        
                                    for searchAsset in searchAssets {
                                        if asset.memory.id == searchAsset.memory.id {
                                            assetDisplayed = true
                                        }
                                    }
                                    if !assetDisplayed {
                                        searchAssets.append(CustomAsset(memory: asset.memory))
                                    }
                                }
                            } else {
                                if tags.contains(searchTag) {
                                    var assetDisplayed = false
                                        
                                    for searchAsset in searchAssets {
                                        if asset.memory.id == searchAsset.memory.id {
                                            assetDisplayed = true
                                        }
                                    }
                                    if !assetDisplayed {
                                        searchAssets.append(CustomAsset(memory: asset.memory))
                                    }
                                }
                            }
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
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .bookmark, state: .normal)
        searchController.searchBar.keyboardType = .twitter
        
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
                
                if let thumbnail = CustomAsset.memory.thumbnail {
                    if let image = thumbnail.image {
                        cell.thumbnailImage = UIImage(data: image)
                    }
                }
//                if let story = CustomAsset.memory.story {
//                    let filtered = story.components(separatedBy: "\n")
//                    if filtered.count > 0 {
//                        cell.title = filtered.first
//                    } else {
//                        cell.title = story
//                    }
//                } else {
//                    cell.title = nil
//                }
                return cell
            case .movieComponents:
                guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieComponentCollectionViewCell.reuseIdentifer,
                for: indexPath) as? MovieComponentCollectionViewCell else { fatalError("Could not create new cell") }
                
                if let thumbnail = CustomAsset.memory.thumbnail {
                    if let image = thumbnail.image {
                        cell.thumbnailImage = UIImage(data: image)
                    }
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
      let layout = UICollectionViewCompositionalLayout {
        (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        
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
          widthDimension: .absolute(120),
          heightDimension: .absolute(100))
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
extension PhotoAssetsViewController: UICollectionViewDelegate, UIGestureRecognizerDelegate {

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        switch indexPath.section {
        case 0:
            let menuConfig = UIContextMenuConfiguration(identifier: "Movie Component Menu" as NSCopying, previewProvider: nil) { (menuElement) -> UIMenu? in
                
                let delete = UIAction(title: "Remove", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { (action) in
                    
                    DispatchQueue.main.async {
                        self.movieComponents.remove(at: indexPath.row)
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
                guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                let send = UIAction(title: "Send Photo", image: nil, identifier: nil, discoverabilityTitle: nil) { (action) in
                    if let thumbnail = selectedAsset.memory.thumbnail {
                        if let imageData = thumbnail.image {
                            do {
                                var settings = RenderSettings()
                                settings.videoFilename = "memory"
                                settings.videoFilenameExt = "jpeg"
                                try imageData.write(to: settings.outputURL)
                                
                                var message = ""
                                if let story = selectedAsset.memory.story {
                                    message = story
                                }
                                let activityItems = [settings.outputURL, message] as [Any]
                                let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                                
                                activityController.popoverPresentationController?.sourceView = self.view
                                activityController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 100, height: 200) // you can set this as per your requirement.
                                
                                self.present(activityController, animated: true, completion: nil)
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                
                let _ = UIAction(title: "Preview in AR", image: UIImage(systemName: "arkit"), identifier: nil, discoverabilityTitle: nil) {
                    (action) in
                    
                }
                
                let shareMenu = UIMenu(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil, children: [send])
                
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "minus.circle"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { (action) in
                    
                    DispatchQueue.main.async {
                        if let delegate = self.appDelegate {
                            let managedObjectContext = delegate.persistentContainer.viewContext
                            
                            guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else { return }
                            managedObjectContext.delete(selectedAsset.memory)
                            
                            if self.searchAssets.count > indexPath.row {
                                self.searchAssets.remove(at: indexPath.row)
                            }
                            
                            do {
                                try managedObjectContext.save()
                            } catch let error {
                                print("Could not save into Core Data. Error: \(error), \(error.localizedDescription)")
                            }
                            print("Memory removed from Core Data.")
                            NotificationCenter.default.post(name: .CoreDataUpdate, object: nil)
                            self.snapshotForCurrentState()
                        }
                    }
                }
                let detail = UIAction(title: "Details", image: UIImage(systemName: "info.circle")) { (action) in
                    let storyboard = UIStoryboard(name: "MemoirViewController", bundle: nil)
                    if let detail = storyboard.instantiateViewController(withIdentifier: "AssetDetailID") as? AssetDetailViewController {
                        guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else {
                            return
                        }
                        
                        detail.hidesBottomBarWhenPushed = true
                        detail.memory = selectedAsset.memory
                        detail.memoryIndex = indexPath.row
                        AssetDetailViewController.assetFileSize = nil
                        
                        if let navigation = self.navigationController {
                            navigation.pushViewController(detail, animated: true)
                        }
                    }
                }
                let addMovieComponent = UIAction(title: "Movie component", image: UIImage(systemName: "plus.circle"), identifier: nil, discoverabilityTitle: nil) { (action) in
                    
                    guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else {
                        return
                    }
                    self.videoButton.isEnabled = true
                    
                    DispatchQueue.main.async {
                        self.movieComponents.append(CustomAsset(memory: selectedAsset.memory))
                        self.snapshotForCurrentState()
                    }
                }
                let menu = UIMenu(title: "", image: nil, identifier: .none, options: .displayInline, children: [detail, shareMenu, addMovieComponent, delete])
                return menu
            }
            return menuConfig
        default:
            return nil
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // handling code
            if let lastView = view.subviews.last {
                lastView.removeFromSuperview()
            }
            if let navigation = navigationController {
                navigation.navigationBar.isHidden = false
            }
            if let tabBar = tabBarController {
                tabBar.tabBar.isHidden = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            feedbackGenerator.impactOccurred()
            guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else { return }
            //add view
            let photoView = UIView(frame: CGRect(origin: view.frame.origin, size: view.frame.size))
            photoView.backgroundColor = .black
            
            if let navigation = navigationController {
                navigation.navigationBar.isHidden = true
            }
            if let tabBar = tabBarController {
                tabBar.tabBar.isHidden = true
            }
            
            view.addSubview(photoView)
            view.bringSubviewToFront(photoView)
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            photoView.addGestureRecognizer(dismissTap)
            //add imageview
            if let thumbnail = selectedAsset.memory.thumbnail {
                if let imageData = thumbnail.image {
                    if let image = UIImage(data: imageData, scale: 1.0) {
                        let imageView = UIImageView(image: image)
                        
                        imageView.contentMode = .scaleAspectFill
                        imageView.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height / 4), size: CGSize(width: view.frame.width, height: view.frame.height / 2))
                        imageView.clipsToBounds = true
                        imageView.layer.cornerRadius = 20
                        
                        photoView.addSubview(imageView)
                    }
                }
            }
        default:
            break
        }
    }
}

// MARK: UIContextMenuInteractionDelegate
