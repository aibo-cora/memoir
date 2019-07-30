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
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func createMemoirPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: String(describing: CreateMemoirViewController.self),
                                      bundle: nil)
        let createMemoirViewController = storyboard.instantiateInitialViewController()!
        present(createMemoirViewController,
                animated: true) {
                    // code after createMemoir is displayed
              //      self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toAddMemoirSegue" {
            let popup = segue.destination as! AddMemoirViewController
            
            popup.doneSaving = { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}
