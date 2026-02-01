//
//  FragmentVideoPlayerView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/31/26.
//

import UIKit

class FragmentVideoPlayerView: UIView, PlaylistVideoPlayerDelegate, StepSliderDelegate, UIScrollViewDelegate
{
    // MARK: public outlets properties
    
    @IBOutlet weak var videoScrollView: VideoScrollView!
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var zoomingView: ZoomingView!

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
    
    @IBOutlet var videoViewTapGestureRecognizer: UITapGestureRecognizer!
    
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
            setPreferredVideoSize(CGSize(width: 1280, height: 720)) //?? move?
            _player!.play(withFiles: ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                                              "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"])
            _ = _player!.setVideoSpeed(1.7)
            videoScrollView.isUserInteractionEnabled = true //??
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
    
    @IBAction func tapped(_ sender: Any) {
        //??
        
    }
    
    // MARK: private functions
    
    private func setButtonPermanentColor() {
        let tintColor = UIColor.white
        self.playButton.tintColor = tintColor
        self.fastForwardButton.tintColor = tintColor
        self.rewindButton.tintColor = tintColor
        self.skipNextButton.tintColor = tintColor
        self.skipPrevButton.tintColor = tintColor
        self.speedButton.tintColor = tintColor
    }
    
    private func configureSlidingTimeLabel() { //?? move to own class?
        self.timeScaleView.slidingTimeLabel.textAlignment = .center
        self.timeScaleView.slidingTimeLabel.backgroundColor =  UIColor.black.withAlphaComponent(0.5)//?? -> to constants
        self.timeScaleView.slidingTimeLabel.textColor = UIColor.white
        self.timeScaleView.slidingTimeLabel.layer.cornerRadius = 5.0 //?? -> to constants
        self.timeScaleView.slidingTimeLabel.clipsToBounds = true
    }
    
    private func configureVideoScrollView() {
        //?? to constants
        self.videoScrollView.delegate = self
        self.videoScrollView.minimumZoomScale = 1
        self.videoScrollView.maximumZoomScale = 2
        self.videoScrollView.showsVerticalScrollIndicator = false
        self.videoScrollView.showsHorizontalScrollIndicator = false
        self.videoScrollView.bounces = false
        self.videoScrollView.contentInsetAdjustmentBehavior = .never
        self.videoScrollView.stickToBounds = true
    }
    
    private func customInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self).first as! UIView
        self.contentView = view
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        
        setButtonPermanentColor()
        configureSlidingTimeLabel()
        configureVideoScrollView()
        
        self.timeScaleView.timeSlider.delegate = self
        
        self.videoViewTapGestureRecognizer.require(
            toFail: self.videoScrollView.doubleTapGestureRecognizer)
        
        //?? private vars init
        
        showPlayButton()
        
        //??
        videoScrollView.isUserInteractionEnabled = false //??
        _player = PlaylistVideoPlayer(videoView:self.videoView, noAudio: true)
        _player.delegate = self
        let ss = UIScreen.main.bounds.size
        let newSize = CGSize(width: CGFloat.maximum(ss.height, ss.width),
                             height: CGFloat.minimum(ss.height, ss.width)) //?? so ok?
        setPreferredVideoSize(newSize)
        //??
    }
    
    private func showPlayButton() {
        
    }
    
    private func setPreferredVideoSize(_ videoSize: CGSize) { //?? rename
        if videoSize.equalTo(CGSizeZero) {
            return
        }
        
        let scale = UIScreen.main.scale
        var vs = videoSize
        
        vs.height = (vs.height / scale).rounded(.down)
        vs.width = (vs.width / scale).rounded(.down)
        
        self.videoView.originalVideoSize = vs
        
        let ss = UIScreen.main.bounds.size
        var newSize = CGSize(width: CGFloat.maximum(ss.height, ss.width),
                             height: CGFloat.minimum(ss.height, ss.width))
        
        if vs.width < newSize.width {
            let p = vs.height / vs.width
            newSize.height = (vs.height + (newSize.width - vs.width) * p).rounded(.down)
            vs = CGSize(width: newSize.width, height: newSize.height)
        }
        
        self.zoomingView.bounds = CGRect(x: 0, y: 0, width: vs.width, height: vs.height)
        self.videoScrollView.setNeedsReconfigure()
    }
    
    // MARK: StepSliderDelegate
    
    func stepSlider(_ slider: StepSlider, didChangeValue value: NSNumber) {
        
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingView
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
