//
//  PlayerViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

class PlayerViewController: UIViewController, FragmentVideoPlayerViewDelegate {
    @IBOutlet weak var contentView: UIView!
    
    private let _videoPlayerView: FragmentVideoPlayerView = FragmentVideoPlayerView()
    private var _hidePlayerToolsTask: Task<Void, Never>?
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func attachPlayerView() {
        //?? set date _videoPlayerView.dateLabel.text =
        self.navigationItem.title = "DD:MM:YY" //?? best variant?
        
        _videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        _videoPlayerView.delegate = self
        self.contentView.addSubview(_videoPlayerView)
        let subviews = ["view" : _videoPlayerView]
        let constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[view]-0-|", metrics: nil, views: subviews)
        self.contentView.addConstraints(constraints)
        
        let safeAreaGuide = self.contentView.safeAreaLayoutGuide
        let leading = _videoPlayerView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor)
        let trailing = _videoPlayerView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor)
        
        self.contentView.addConstraints([leading, trailing])
        
        //??
        let videoInfoList: VideoFileList = VideoFileList()
        videoInfoList.append(creationTime: 0, duration: 596, path: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", size: CGSize(width: 1280, height: 720))
        videoInfoList.append(creationTime: 44000, duration: 567, path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", size: CGSize(width: 1280, height: 720))
        videoInfoList.append(creationTime: 60000, duration: 567, path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", size: CGSize(width: 1280, height: 720))
        
        _videoPlayerView.startPlayer(videoFileList: videoInfoList, videoSize: videoInfoList.first!.info.size)
        //??
    }
    
    private func hidePlayerTools(_ hidden: Bool) {
        _videoPlayerView.hideTools(hidden)
        self.navigationController?.setNavigationBarHidden(hidden, animated: true)
    }
    
    private func hidePlayerTools(_ hidden: Bool, delaySec: UInt64 = 2) async {
        do {
            try await Task.sleep(nanoseconds: delaySec * 1_000_000_000)
        } catch {}
        
        if hidden && UIWindow.isLandscape {
            self.hidePlayerTools(hidden)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachPlayerView()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            _ = self._videoPlayerView.restorePlayer()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            self._videoPlayerView.suspendPlayer()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !UIWindow.isLandscape {
            self.hidePlayerTools(false)
        } else {
            _hidePlayerToolsTask?.cancel()
            _hidePlayerToolsTask = Task() {
                await hidePlayerTools(true)
            }
        }
    }
    
    func videoViewTapped() {
        var hidden = false
        if UIWindow.isLandscape {
            hidden = !_videoPlayerView.toolsHidden
        }
        
        self.hidePlayerTools(hidden)
    }
}
