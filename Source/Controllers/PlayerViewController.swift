//
//  PlayerViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

class PlayerViewController: UIViewController, FragmentVideoPlayerViewDelegate {
    private struct Constants {
        static let kHidePlayerToolsDelaySec: Double = 2.0
    }

    @IBOutlet weak var contentView: UIView!
    
    var videoFileList: VideoFileList?
    var videoSize: CGSize = .zero
    
    private let _videoPlayerView = FragmentVideoPlayerView()
    private var _hidePlayerToolsWorkItem: DispatchWorkItem?
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    deinit {
        easyLog(self.className)
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

    private func hidePlayerTools(_ hidden: Bool, delaySec: Double) {
        _hidePlayerToolsWorkItem?.cancel()
        _hidePlayerToolsWorkItem = DispatchWorkItem {
            [weak self] in
            if self?._hidePlayerToolsWorkItem?.isCancelled ?? true {
                return
            }
            if hidden && UIWindow.isLandscape {
                self?.hidePlayerTools(hidden)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec,
                                      execute: _hidePlayerToolsWorkItem!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        attachPlayerView()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) {
                [weak self] _ in
                self?._videoPlayerView.restorePlayer()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) {
                [weak self] _ in
                self?._videoPlayerView.suspendPlayer()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !UIWindow.isLandscape {
            self.hidePlayerTools(false)
        } else {
            self.hidePlayerTools(true, delaySec: Constants.kHidePlayerToolsDelaySec)
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
