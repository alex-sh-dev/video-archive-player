//
//  PlayerViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

class PlayerViewController: UIViewController, FragmentVideoPlayerViewDelegate {
    @IBOutlet weak var contentView: UIView!
    
    var videoFileList: VideoFileList? = nil
    var videoSize: CGSize = .zero
    
    private let _videoPlayerView: FragmentVideoPlayerView = FragmentVideoPlayerView()
    private var _hidePlayerToolsTask: Task<Void, Never>?
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func attachPlayerView() {
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
        _videoPlayerView.startPlayer(videoFileList: self.videoFileList ?? VideoFileList(), videoSize: self.videoSize)
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
