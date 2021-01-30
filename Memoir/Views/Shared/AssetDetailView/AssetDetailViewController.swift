//
//  AssetDetailViewController.swift
//  Memoir
//
//  Created by Yura on 8/31/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit
import AVKit
import CoreData

class AssetDetailViewController: UIViewController {
    var memory: Memory?
    var memoryIndex: Int?
    
    var player: AVPlayer?
    
    let textView = UITextView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 0)))
    
    var keyboardHeight: CGFloat = 0
    var displayViewHeight: CGFloat = 0
    @IBOutlet weak var displayView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var ratingStepper: UIStepper!
    
    @IBOutlet weak var manageTagsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let title = memory?.title {
            navigationItem.title = title
        }
        textView.delegate = self
        
        if let memory = memory {
            configureUI(memory: memory)
            ratingStepper.value = Double(memory.rating)
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            // Save story, tags, rating to context. Info stays the same
            // Send notification to apply a new snapshot to reload data
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            
            Utility.saveContext(message: "Memory updated in Core Data.")
            
            if let memory = memory {
                managedObjectContext.refresh(memory, mergeChanges: true)
            }
            
            NotificationCenter.default.post(name: .CoreDataUpdate, object: nil)
        }
        if let player = player {
            player.pause()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if let memory = memory {
            configureUI(memory: memory)
        }
    }

    @IBAction func ratingChanged(_ sender: UIStepper) {
        if let memory = memory {
            memory.rating = Int16(sender.value)
            configureUI(memory: memory)
        }
    }
    
    /// This function is responsible for filtering out the text entered by the user. It removes whitespaces and potential dublicate tags in the memory object.
    /// - Parameter sender: Button
    @IBAction func manageTags(_ sender: UIButton) {
        let alert = UIAlertController(title: "Manage Tags", message: "Add or remove tags from this memory.", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "List tags separated by a comma"
            textfield.keyboardType = .twitter
        }
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let textfields = alert.textFields {
                if !textfields.isEmpty {
                    if let textFieldText = textfields[0].text {
                        let parsedTags = self.parseText(tags: textFieldText)
                        if let memory = self.memory {
                            if let tags = memory.tags {
                                let separateMemory = tags.components(separatedBy: [","])
                                let separate = parsedTags.components(separatedBy: [","])
                                var noDuplicates = ""
                                for count in 0..<separate.count {
                                    if separateMemory.contains(separate[count]) {
                                        
                                    } else {
                                        noDuplicates.append(separate[count])
                                        noDuplicates.append(",")
                                    }
                                }
                                noDuplicates.append(tags)
                                noDuplicates = noDuplicates.filter { $0 != "#"}
                                noDuplicates = noDuplicates.filter { $0 != "+"}
                                memory.tags = noDuplicates
                            } else {
                                memory.tags = parsedTags
                            }
                            self.configureUI(memory: memory)
                        }
                    }
                }
            }
        }
        let remove = UIAlertAction(title: "Remove", style: .destructive) { (action) in
            if let textfields = alert.textFields {
                if !textfields.isEmpty {
                    if let textFieldText = textfields[0].text {
                        let parsedTags = self.parseText(tags: textFieldText)
                        if let memory = self.memory {
                            if let tags = memory.tags {
                                var separateMemory = tags.components(separatedBy: [","])
                                let separate = parsedTags.components(separatedBy: [","])
                                var noDuplicates = ""
                                for count in 0..<separate.count {
                                    if separateMemory.contains(separate[count]) {
                                        separateMemory = separateMemory.filter { $0 != separate[count]
                                        }
                                    }
                                }
                                for count in 0..<separateMemory.count {
                                    noDuplicates.append(separateMemory[count])
                                    noDuplicates.append(",")
                                }
                                noDuplicates = noDuplicates.filter { $0 != "#"}
                                noDuplicates = noDuplicates.filter { $0 != "+"}
                                memory.tags = noDuplicates
                                self.configureUI(memory: memory)
                            }
                        }
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(add)
        alert.addAction(remove)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func parseText(tags: String) -> String {
        var result = tags.filter { !$0.isWhitespace }
        result = result.lowercased()
        result = result.filter { $0 != "#"}
        result = result.filter { $0 != "+"}
        
        var separate = result.components(separatedBy: ",")
        var noDuplicates = ""
        
        separate = separate.sorted()
        
        for count in 0..<separate.count - 1 {
            if separate[count] == separate[count + 1] {
            } else {
                noDuplicates.append(separate[count])
                noDuplicates.append(",")
            }
        }
        if let tail = separate.last {
            noDuplicates.append(tail)
        }
        return noDuplicates
    }
}
