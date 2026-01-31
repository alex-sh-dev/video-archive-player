//
//  ViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

class StartViewController: UIViewController {
    private var _player: PlaylistVideoPlayer? = nil //??
    
    @IBOutlet weak var contentView: UIView! //?? remove from storyboard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //??
        _player = PlaylistVideoPlayer(videoView: self.contentView, noAudio: true)
        _player!.play(withFiles: ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"])
        _ = _player!.setVideoSpeed(1.7)
        //??
    }
    
    //??
    func playAtPosition() async {
        do {
            try await Task.sleep(nanoseconds: 20 * 1_000_000_000) // 20 secs
        } catch {
            print(error)
        }
        _ = _player!.play(fromPlaylistAt: 0, startTime: 1)
    }
    //??
    
    //??
    override func viewDidAppear(_ animated: Bool) {
        Task(priority: .medium) {
            await playAtPosition()
        }
    }
    //??
}
