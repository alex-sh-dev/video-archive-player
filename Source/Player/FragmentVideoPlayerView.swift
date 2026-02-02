//
//  FragmentVideoPlayerView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/31/26.
//

import UIKit

private struct PlayerPosition
{
    var index: PlaylistItemIndex = .first
    var time: UInt = 0
    
    init(index: PlaylistItemIndex, time: UInt) {
        self.index = index
        self.time = time
    }
}

final class FragmentVideoPlayerView: UIView, PlaylistVideoPlayerDelegate,
                                     StepSliderDelegate, VideoViewDelegate
{
    // MARK: public outlets properties
    
    @IBOutlet weak var videoScrollView: VideoScrollView!

    @IBOutlet weak var timeScaleView: TimeScaleView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var skipNextButton: UIButton!
    @IBOutlet weak var skipPrevButton: UIButton!
    
    @IBOutlet weak var speedButton: UIButton!

    @IBOutlet weak var mainButtonGroup: UIView!
    @IBOutlet weak var extraButtonGroup: UIView!

    @IBOutlet weak var activityIndicatorBackgroundView: ActivityIndicatorBackgroundView!
    
    // MARK: private properties
    
    private weak var contentView: UIView!
    private var _player: PlaylistVideoPlayer!
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    // MARK: actions
    
    @IBAction func buttonTapped(sender: UIButton) {
        switch (sender) {
        case self.playButton:
            //??
            self.videoScrollView.specifyVideoSize(CGSize(width: 1280, height: 720))
            _player!.play(withFiles: ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                                              "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"])
            _ = _player!.setVideoSpeed(1.7)
            videoScrollView.isUserInteractionEnabled = true
            //??
        case self.fastForwardButton:
            break
        case self.rewindButton:
            break
        case self.skipNextButton:
            break
        case self.skipPrevButton:
            break
        case self.speedButton:
            break
        default:
            break
        }
    }
    
    // MARK: private functions
    
    private func customInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self).first as! UIView
        self.contentView = view
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        
        self.timeScaleView.timeSlider.delegate = self
        self.videoScrollView.videoView.delegate = self
        
        //?? private vars init
        
        showPlayButton()
        
        //??
        videoScrollView.isUserInteractionEnabled = false
        _player = PlaylistVideoPlayer(videoView:self.videoScrollView.videoView, noAudio: true)
        _player.delegate = self
        //??
    }
    
    //?? print(player.videoSize) может так получать?
    
    private func showPlayButton() {
        
    }
    
    // MARK: VideoViewDelegate
    
    func videoViewTapped() {
    }
    
    // MARK: StepSliderDelegate
    
    func stepSlider(_ slider: StepSlider, didChangeValue value: NSNumber) {
        
    }
    
    // MARK: PlaylistVideoPlayerDelegate
    
    func playerHasStartedBuffering(player: PlaylistVideoPlayer) {
        self.activityIndicatorBackgroundView.isHidden = false
    }
    
    func playerHasCompletedBuffering(player: PlaylistVideoPlayer) {
        self.activityIndicatorBackgroundView.isHidden = true
    }
    
    //?? add other functions of protocol
}
