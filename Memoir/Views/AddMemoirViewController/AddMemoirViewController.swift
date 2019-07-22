//
//  AddMemoirViewController.swift
//  Memoir
//
//  Created by Yura on 7/20/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit

class AddMemoirViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memoirNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.addShadowRoundedCorners()
        popupView.backgroundColor = Theme.accent
        
        titleLabel.font = UIFont(name: Theme.mainFontName, size: 24)
    }

    @IBAction func save(_ sender: UIButton) {
        dismiss(animated: true) {
            //
        }
    }
    
    @IBAction func cencel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
