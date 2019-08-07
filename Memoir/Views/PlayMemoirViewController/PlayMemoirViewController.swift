//
//  PlayMemoirViewController.swift
//  Memoir
//
//  Created by Yura on 8/6/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import UIKit
import AVFoundation

class PlayMemoirViewController: UIViewController {
    
    var fileToPlayback: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playFile()
    }
    
    func playFile() {
        if let videoURL = fileToPlayback {
            let player = AVPlayer(url: videoURL)
            
            player.play()
        }
        
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
