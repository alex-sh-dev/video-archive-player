//
//  ViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

class StartViewController: UIViewController {
    private var _player: PlaylistVideoPlayer? = nil //??
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //??
        _player = PlaylistVideoPlayer(videoView: self.view)
        _player!.play(withFile: "https://samplelib.com/lib/preview/mp4/sample-5s.mp4")
        //??
    }
}
