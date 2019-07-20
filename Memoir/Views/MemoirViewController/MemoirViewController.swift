//
//  MemoirViewController.swift
//  Memoir
//
//  Created by Yura on 7/15/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class MemoirViewController: UIViewController {
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        MemoirFunctions.showMemoirs { [weak self] in
            // completion
            self?.tableView.reloadData()
        }
        
        view.backgroundColor = Theme.accent
        
        plusButton.makeFloatingActionButton()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
