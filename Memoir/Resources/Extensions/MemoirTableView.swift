//
//  MemoirTableViewExtension.swift
//  Memoir
//
//  Created by Yura on 7/17/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import Foundation
import UIKit

extension MemoirViewController: UITableViewDataSource,
                                UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemoirData.memoirData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let memoirCell = tableView.dequeueReusableCell(withIdentifier: "memoirCell") as! MemoirTableViewCell
        
        
        memoirCell.setup(memoir: MemoirData.memoirData[indexPath.row])
        return memoirCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive,
                                        title: "Delete")
        { (action, view, actionPerformed: @escaping (Bool) -> (Void)) in
            let alert = UIAlertController(title: "Confirm Delete Memoir",
                                        message: "Are you sure you want to delete this Memoir?",
                                 preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "No",
                                       style: .cancel,
                                     handler: { (action) in
                                                    actionPerformed(false)
                                            })
            let delete = UIAlertAction(title: "Delete",
                                       style: .destructive,
                                       handler: { (action) in
                                                // perform delete
                                                MemoirFunctions.deleteMemoir(index: indexPath.row)
                                                //  tableView.reloadData()
                                                tableView.deleteRows(at: [indexPath],
                                                                     with: .automatic)
                                                actionPerformed(true)
                                            })
                                        
            alert.addAction(cancel)
            alert.addAction(delete)
            self.present(alert, animated: true)
        }
        delete.title = "Trash"
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
