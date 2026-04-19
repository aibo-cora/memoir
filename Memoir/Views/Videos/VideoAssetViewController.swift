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
import AVKit
import GoogleSignIn

import SwiftUI

enum AssetExportState {
    case beingExported, ready
}

class VideoAssetViewController: UIViewController {
    
    enum Section: String, CaseIterable, Hashable {
      case media = "Memories"
    }
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var assets = [CustomAsset]()
    var searchAssets = [CustomAsset]()
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    // MARK: - Value Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CustomAsset>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CustomAsset>
    
    private var searchController = UISearchController(searchResultsController: nil)
    var assetsCollectionView: UICollectionView! = nil
    var dataSource: DataSource! = nil
    
    var videoBeingEdited: Video? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // add observer
        NotificationCenter.default.addObserver(self, selector: #selector(fetchMemories(_:)), name: .CoreDataFetchVideoAssets, object: nil)
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
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [])
        } catch {
            
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
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController {
            if let createController = destination.topViewController as? CreateMemoirGridController {
                createController.mediaType = "video"
            }
        }
    }
    
    // MARK: Actions
    @IBAction func takeVideo(_ sender: UIBarButtonItem) {
        configureCamera()
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
            
            for memory in result {
                assets.append(CustomAsset(memory: memory))
            }
            snapshotForCurrentState()
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension VideoAssetViewController: UISearchResultsUpdating {
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
extension VideoAssetViewController {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: AssetCollectionViewCell.reuseIdentifer)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: VideoAssetViewController.sectionHeaderElementKind, withReuseIdentifier: HeaderView.reuseIdentifier)
        
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
                    if let media = thumbnail.image {
                        cell.thumbnailImage = UIImage(data: media)
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
      let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        _ = layoutEnvironment.container.effectiveContentSize.width > 500

        let sectionLayoutKind = Section.allCases[sectionIndex]
        
        switch sectionLayoutKind {
        case .media:
            return self.generateAssetsLayout()
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
    
    func snapshotForCurrentState() {
        var snapshot = Snapshot()
        
        snapshot.appendSections([Section.media])
        
        if searchAssets.count > 0 {
            snapshot.appendItems(searchAssets, toSection: Section.media)
        } else {
            snapshot.appendItems(assets, toSection: Section.media)
        }
        
        if let dataSource = dataSource {
            dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
                self?.scrollToItem()
            }
        }
    }
    
    func scrollToItem() {
        let itemsCount = assetsCollectionView.numberOfItems(inSection: 0)
        guard itemsCount > 0 else { return }
        
        let targetRow = min(assets.count / 2, itemsCount - 1)
        let indexPath = IndexPath(row: targetRow, section: 0)
        
        assetsCollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
}

// MARK: UICollectionViewDelegate
extension VideoAssetViewController: UICollectionViewDelegate {
    /// After a preview gets displayed, Core Data loads the entity into memory. This method is used to deallocate that memory when the preview is dismissed.
    /// - Parameters:
    ///   - collectionView: Collection view.
    ///   - configuration: Configuration.
    /// - Returns: nil.
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        if let appDelegate = appDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            if let memory = Utility.selectedMemoryToPreview {
                managedContext.refresh(memory, mergeChanges: false)
            }
        }
        Utility.selectedMemoryToPreview = nil
        
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        switch indexPath.section {
        case 0:
            let menuConfig = UIContextMenuConfiguration(identifier: "Asset Menu" as NSCopying, previewProvider: { () -> UIViewController? in
                
                guard let selectedAsset = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                Utility.selectedMemoryToPreview = selectedAsset.memory
                return MemoryPreviewViewController(memory: selectedAsset.memory)
                
            }) { [unowned self] (menuElement) -> UIMenu? in
                guard let selectedAsset = dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                let detail = UIAction(title: "Details", image: UIImage(systemName: "info.circle")) { (action) in
                    let storyboard = UIStoryboard(name: "MemoirViewController", bundle: nil)
                    if let detail = storyboard.instantiateViewController(withIdentifier: "AssetDetailID") as? AssetDetailViewController {
                        guard let selectedAsset = dataSource.itemIdentifier(for: indexPath) else {
                            return
                        }
                        
                        detail.hidesBottomBarWhenPushed = true
                        detail.memory = selectedAsset.memory
                        detail.memoryIndex = indexPath.row
                        
                        if let navigation = navigationController {
                            navigation.pushViewController(detail, animated: true)
                        }
                    }
                }
                let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { (action) in
                    DispatchQueue.main.async {
                        if let videoEntity = selectedAsset.memory.video {
                            let settings = RenderSettings()
                            
                            do {
                                try videoEntity.video?.write(to: settings.outputURL)
                                
                                if UIVideoEditorController.canEditVideo(atPath: settings.outputURL.path) {
                                    
                                    videoBeingEdited = videoEntity
                                    
                                    let editController = UIVideoEditorController()
                                    editController.videoPath = settings.outputURL.path
                                    editController.delegate = self
                                    editController.modalPresentationStyle = .fullScreen
                                    
                                    present(editController, animated:true)
                                } else {
                                    let alert = UIAlertController(title: "Error", message: "This video cannot be edited.", preferredStyle: .alert)
                                    present(alert, animated: true) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            } catch {
                                return
                            }
                        }
                    }
                }
                let record = UIAction(title: "Record", image: UIImage(systemName: "mic.fill"), identifier: nil, discoverabilityTitle: nil) {
                    (action) in
                        
                    let storyboard = UIStoryboard(name: "MemoirViewController", bundle: nil)
                    if let record = storyboard.instantiateViewController(withIdentifier: "RecordingID") as? Recording {
                        record.video = selectedAsset.memory.video
                        record.memory = selectedAsset.memory
                        record.hidesBottomBarWhenPushed = true
                        
                        if let navigation = self.navigationController {
                            navigation.pushViewController(record, animated: false)
                        }
                    }
                    
                }
                let song = UIAction(title: "Song", image: UIImage(systemName: "music.note.list"), identifier: nil, discoverabilityTitle: nil) { (action) in
                    
                    let storyboard = UIStoryboard(name: "MemoirViewController", bundle: nil)
                    if let song = storyboard.instantiateViewController(withIdentifier: "SongID") as? SongViewController {
                        song.video = selectedAsset.memory.video
                        song.hidesBottomBarWhenPushed = true
                        
                        if let navigation = self.navigationController {
                            navigation.pushViewController(song, animated: false)
                        }
                    }
                }
                let audioMenu = UIMenu(title: "Audio", image: UIImage(systemName: "plus.circle"), identifier: nil, children: [song, record])
                
                let sendLink = UIAction(title: "Send YouTube Link", image: UIImage(systemName: "link"), identifier: nil, discoverabilityTitle: nil) { (action) in
 
                    let message = selectedAsset.memory.story
                    
                    if let video = selectedAsset.memory.youtubeURL {
                        let activityItems = [video, message as Any] as [Any]
                        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                        
                        activityController.popoverPresentationController?.sourceView = view
                        activityController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 100, height: 200) // you can set this as per your requirement.
                        
                        present(activityController, animated: true, completion: nil)
                    } else {
                        // the video has not been uploaded
                        let alert = UIAlertController(title: "Sharing Error", message: "Please upload the video to your YouTube channel before attempting to share it with someone.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }
                }
                let sendVideo = UIAction(title: "Send Video", image: UIImage(systemName: "message"), identifier: nil, discoverabilityTitle: nil) { (action) in
                    if let videoEntity = selectedAsset.memory.video {
                        if let videoData = videoEntity.video {
                            do {
                                let settings = RenderSettings()
                                if FileManager.default.fileExists(atPath: settings.outputURL.path) {
                                    try FileManager.default.removeItem(at: settings.outputURL)
                                }
                                try videoData.write(to: settings.outputURL)
                                
                                var message = ""
                                if let story = selectedAsset.memory.story {
                                    message = story
                                }
                                let activityItems = [settings.outputURL, message] as [Any]
                                let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                                
                                activityController.popoverPresentationController?.sourceView = view
                                activityController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: view.bounds.midY, width: 100, height: 200) // you can set this as per your requirement.
                                
                                present(activityController, animated: true, completion: nil)
                                
                            } catch {
                            }
                        }
                    }
                }
                let upload = UIAction(title: "Upload to YouTube", image: UIImage(named: "youtube.icon"), identifier: nil, discoverabilityTitle: nil) {
                    (action) in
                    if let _ = GIDSignIn.sharedInstance()?.currentUser {
                        let hostingController = UIHostingController(rootView: ConfigureUploadUI(parentController: self, videoAsset: selectedAsset))
                        
                        present(hostingController, animated: true)
                    } else {
                        // No user is logged in
                        let alert = UIAlertController(title: "Upload Error", message: "Please log in to your Google account in Settings before attempting to upload.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                    }
                }
                
                let shareMenu = UIMenu(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil, children: [sendVideo, sendLink, upload])
                
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "minus.circle"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { (action) in
                    
                    DispatchQueue.main.async {
                        if let delegate = appDelegate {
                            let managedObjectContext = delegate.persistentContainer.viewContext
                            
                            guard let selectedAsset = dataSource.itemIdentifier(for: indexPath) else { return }
                            managedObjectContext.delete(selectedAsset.memory)
                            
                            if searchAssets.count > indexPath.row {
                                searchAssets.remove(at: indexPath.row)
                            }
                            
                            Utility.saveContext(message: "Memory removed from Core Data.")
                            NotificationCenter.default.post(name: .AssetDeleted, object: nil)
                            NotificationCenter.default.post(name: .CoreDataUpdate, object: nil)
                            snapshotForCurrentState()
                        }
                    }
                }
                
                let menu = UIMenu(title: "", image: nil, identifier: .none, options: .displayInline, children: [detail, edit, shareMenu, audioMenu, delete])
                return menu
            }
            return menuConfig
        default:
            return nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedAsset = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        feedbackGenerator.impactOccurred()
        
        let settings = RenderSettings()
        if let videoEntity = selectedAsset.memory.video {
            if let video = videoEntity.video {
                do {
                    try video.write(to: settings.outputURL)
                } catch {
                    return
                }
                
                do {
                    let resources = try settings.outputURL.resourceValues(forKeys:[.fileSizeKey])
                    let fileSize = resources.fileSize!
                    print ("\(fileSize)")
                } catch {
                    print("Error: \(error)")
                }
                
                let player = AVPlayer(url: settings.outputURL)
                let controller = AVPlayerViewController()
                
                controller.view.frame = view.frame
                controller.player = player
                
                present(controller,animated: true) {
                    player.isMuted = false
                    player.play()
                }
            }
        }
    }
}

// MARK: UIVideoEditorControllerDelegate

