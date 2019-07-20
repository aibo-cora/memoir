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
}
