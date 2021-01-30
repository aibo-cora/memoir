//
//  ConfigureUI.swift
//  Memoir
//
//  Created by Yura on 9/2/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import AVKit

extension AssetDetailViewController {
    static var assetFileSize: String?
    
    func configureUI(memory: Memory) {
        displayAsset(memory: memory)
        
        ratingStepper.isHidden = true
        textView.allowsEditingTextAttributes = false
        
        if let display = displayView {
            if display.alpha == 0 {
                // the asset is hidden and needs to be shown
                animateUIGoingDown()
            }
        }
        
        let defaultAttributes = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black
        ] as [NSAttributedString.Key : Any]
        let boldTextAttributes = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.black
        ] as [NSAttributedString.Key : Any]
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            // "Info"
            var info = "Information about this memory:\n\n\n"

            if let location = memory.placemark {
                info.append("Location: \(location)\n")
            }
            if let date = memory.creationDate {
                info.append("Date: \(date)\n")
            }
            displayTextView(attributedMessage: NSAttributedString(from: [info], defaultAttributes: defaultAttributes))
        case 1:
            // "Story"
            textView.allowsEditingTextAttributes = true
            if memory.attributedStory == nil {
                displayTextView(canEdit: true, attributedMessage: NSAttributedString(from: ["Tell your story..."], defaultAttributes: defaultAttributes))
            } else {
                displayTextView(canEdit: true, attributedMessage: memory.attributedStory)
            }
            animateUIGoingUp()
        case 2:
            // Tags
            // Configure attributed string
            let welcomeMessage = "Think of as many tags as you can to find this memory faster. Try to answer who/what/when/how/where questions. Tags for this memory are:\n\n\n"
            let tagMessage = NSMutableAttributedString()
            
            if let tagsFullList = memory.tags {
                print(tagsFullList)
                
                var separate = tagsFullList.components(separatedBy: [","])
                separate = separate.sorted()
                for tag in separate {
                    if tag.isEmpty {
                        
                    } else {
                        tagMessage.append(NSAttributedString(string: "#"))
                        tagMessage.append(NSAttributedString(string: tag))
                        tagMessage.append(NSAttributedString(string: "\n "))
                    }
                }
            }
            // Configure and show text view holding tags
            displayTextView(attributedMessage: NSAttributedString(from: [welcomeMessage, tagMessage], defaultAttributes: defaultAttributes))
            // Configure button
            manageTagsButton.isHidden = false
        case 3:
            // "Rating"
            ratingStepper.isHidden = false
            displayTextView(attributedMessage: NSAttributedString(from: ["This rating will determine the order in which your media is displayed. The higher the rating the closer it will be to the top. \n\n\nCurrent rating: ", "\(memory.rating)".toAttributed(with: boldTextAttributes)], defaultAttributes: defaultAttributes))
        default:
            displayTextView(message: "Something went wrong...", canEdit: false)
        }
    }
    
    // MARK: Display UI
    fileprivate func displayAsset(memory: Memory) {
        if let type = memory.mediaType {
            switch type {
            case "image":
                if let thumbnail = memory.thumbnail {
                    if let data = thumbnail.image {
                        let photo = UIImage(data: data)
                        if let image = photo {
                            let imageView = UIImageView(image: image)
                            
                            if let display = displayView {
                                display.addSubview(imageView)
                            }
                            
                            imageView.translatesAutoresizingMaskIntoConstraints = false
                            imageView.contentMode = .scaleAspectFill
                            imageView.clipsToBounds = true
                            imageView.layer.cornerRadius = 20
                            
                            NSLayoutConstraint.activate([
                                imageView.leadingAnchor.constraint(equalTo: displayView.leadingAnchor),
                                imageView.trailingAnchor.constraint(equalTo: displayView.trailingAnchor),
                                imageView.topAnchor.constraint(equalTo: displayView.topAnchor),
                                imageView.bottomAnchor.constraint(equalTo: displayView.bottomAnchor)
                            ])
                        }
                    }
                }
            case "video":
                if let videoEntity = memory.video {
                    if let video = videoEntity.video {
                        let settings = RenderSettings()
                        do {
                            try video.write(to: settings.outputURL)
                            
                            if segmentedControl.selectedSegmentIndex == 0 {
                                let bcf = ByteCountFormatter()
                                
                                bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                                bcf.countStyle = .file
                                AssetDetailViewController.assetFileSize = bcf.string(fromByteCount: Int64(video.count))
                            }
                        } catch {
                            print("Could not get resource values.")
                        }
                        if let display = displayView {
                            if let _ = player {
                            } else {
                                player = AVPlayer(url: settings.outputURL)
                                let playerLayer = AVPlayerLayer(player: player)
                                
                                playerLayer.frame = display.bounds
                                playerLayer.videoGravity = .resizeAspectFill
                                display.layer.addSublayer(playerLayer)
                                
                                if let player = player {
                                    player.play()
                                }
                            }
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    fileprivate func displayTextView(message: String? = nil, canEdit: Bool = false, attributedMessage: NSAttributedString? = nil) {
        
        textView.isEditable = canEdit
        if let attributedMessage = attributedMessage {
            let message = NSMutableAttributedString(attributedString: attributedMessage)
            
            if segmentedControl.selectedSegmentIndex == 0 {
                if let fileSize = AssetDetailViewController.assetFileSize {
                    message.append(NSAttributedString(string: "\n"))
                    message.append(NSAttributedString(string: "File size: ", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
                    message.append(NSAttributedString(string: fileSize, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)]))
                }
            }
            
            textView.attributedText = message
        } else {
            if let text = message {
                textView.text = text
            }
        }
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: 40),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
        
        configureManageTagsButton()
    }
    
    // MARK: Configure UI
    fileprivate func configureManageTagsButton() {
        manageTagsButton.isHidden = true
        manageTagsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            manageTagsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            manageTagsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            manageTagsButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 40),
            manageTagsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    func animateUIGoingUp() {
        if let display = displayView {
            UIView.animate(withDuration: 0.5, animations: {
                display.alpha = 0
            }) { (completed) in
                UIView.animate(withDuration: 0.5) {
                    let safeArea = self.view.safeAreaInsets
                    
                    self.segmentedControl.frame = CGRect(origin: CGPoint(x: safeArea.left + 20, y: safeArea.top + 20), size: self.segmentedControl.frame.size)
                    
                    self.textView.frame = CGRect(origin: CGPoint(x: safeArea.left + 20, y: self.segmentedControl.frame.maxY + 20), size: self.textView.frame.size)
                }
            }
        }
    }
    
    func animateUIGoingDown() {
        UIView.animate(withDuration: 0.5, animations:  {
            
        }) { (completed) in
            UIView.animate(withDuration: 0.5) {
               self.displayView.alpha = 1
            }
        }
    }
}

// MARK: UITextViewDelegate

extension AssetDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let memory = memory {
            memory.attributedStory = textView.attributedText
            memory.story = textView.text
        }
    }
}
