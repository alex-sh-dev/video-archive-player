//
//  PlayerViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

class PlayerViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    
    private let _videoPlayerView: FragmentVideoPlayerView = FragmentVideoPlayerView()
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func attachPlayerView() {
        //?? set date _videoPlayerView.dateLabel.text =
        self.navigationItem.title = "DD:MM:YY" //?? best variant?
        
        _videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(_videoPlayerView)
        let subviews = ["view" : _videoPlayerView]
        let constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[view]-0-|", metrics: nil, views: subviews)
        self.contentView.addConstraints(constraints)
        
        let safeAreaGuide = self.contentView.safeAreaLayoutGuide
        let leading = _videoPlayerView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor)
        let trailing = _videoPlayerView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor)
        
        self.contentView.addConstraints([leading, trailing])
            
        let videoSize = CGSizeZero
        //?? get video size from json or in another way
        
        //?? start player with videoSize, files, startTime
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachPlayerView()
    }
}
