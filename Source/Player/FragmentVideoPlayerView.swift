//
//  FragmentVideoPlayerView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/31/26.
//

import UIKit

private struct PlayerPosition
{
    var index: UInt = 0
    var time: UInt = 0
    
    init() {}
    
    init(index: UInt, time: UInt) {
        self.index = index
        self.time = time
    }
}

private enum PlayButtonIdentity: Int {
    case play = 0
    case pause
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
    
    private var _videoInfoList: VideoFileList?
    
    private var _shouldUpdateTimeSliderValue = false //??
    private var _playerSuspended = false
    private var _needsRestorePosition = false
    private var _lastPosition = PlayerPosition()
    
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
            _videoInfoList = VideoFileList()
            _videoInfoList!.append(creationTime: 0, duration: 10, path: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", size: CGSize(width: 1280, height: 720))
            _videoInfoList?.append(creationTime: 10, duration: 10, path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", size: CGSize(width: 1280, height: 720))
            _videoInfoList?.append(creationTime: 20, duration: 10, path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", size: CGSize(width: 1280, height: 720))
            
            self.videoScrollView.specifyVideoSize(CGSize(width: 1280, height: 720))
            createPlayer()
//            _ = _player!.setVideoSpeed(1.7) //??
            startPlayer(itemIndex: .value(1))
            //??
        case self.fastForwardButton:
            break
        case self.rewindButton:
            break
        case self.skipNextButton:
            skipNextPlaylistItem() //??
            break
        case self.skipPrevButton:
            skipPrevPlaylistItem() //??
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
        
        self.timeScaleView.timeSlider.isUserInteractionEnabled = false
        
        showPlayButton()
    }
    
    private func createPlayer(audioDisabled: Bool = true) {
        //?? player.videoSize best variant?
        videoScrollView.isUserInteractionEnabled = false
        _player = PlaylistVideoPlayer(videoView:self.videoScrollView.videoView, noAudio: audioDisabled)
        _player.delegate = self
    }
    
    private func showPlayButton() {
        let image = UIImage(systemName: "play.fill")
        self.playButton.setImage(image, for: .normal)
        self.playButton.tag = PlayButtonIdentity.play.rawValue
    }
    
    private func showPauseButton() {
        let image = UIImage(systemName: "pause.fill")
        self.playButton.setImage(image, for: .normal)
        self.playButton.tag = PlayButtonIdentity.pause.rawValue
    }
    
    private func startPlayer(itemIndex: PlaylistItemIndex) {
        if _player == nil {
            return
        }
        
        switch (_player.state) {
        case .endReached:
            skipNextPlaylistItem()
            return
        case .paused:
            _player.play()
        case .stopped:
            guard let infoList = _videoInfoList, infoList.count > 0 else {
                return
            }
            
            var creationTime: UInt = 0
            var index: PlaylistItemIndex = .first
            let count = infoList.count
            switch (itemIndex) {
            case .last:
                index = .value(count - 1)
                creationTime = infoList.last!.info.creationTime
                break
            case .first..<PlaylistItemIndex.value(count):
                index = itemIndex
                creationTime = infoList[itemIndex.rawValue]!.info.creationTime
                break
            default:
                break
            }
            
            _player.play(withFiles: infoList.paths, startingFrom: index)
            _lastPosition.index = index.rawValue
            self.timeScaleView.timeSlider.setValue(NSNumber(value: creationTime), animated: false)
        default:
            break
        }
    }
    
    private func pausePlayer() {
        if _player == nil {
            return
        }
        
        if !_player.pause() {
            _player.stop()
        }
    }
    
    private func stopPlayer() {
        if _player == nil {
            return
        }
        
        _player.stop()
    }
    
    private func calcAndSetTimeSliderValue(itemIndex: UInt, time: UInt) {
        if !_playerSuspended {
            _lastPosition = PlayerPosition(index: itemIndex, time: time)
        }
        
        if (self.timeScaleView.timeSlider.isThumbCaptured || _shouldUpdateTimeSliderValue) {
            return
        }
        
        guard let infoList = _videoInfoList, infoList.count > 0 else {
            return
        }
        
        if let vi = infoList[itemIndex] {
            let value = vi.info.creationTime + time
            if value <= self.timeScaleView.timeSlider.maximumValue.uintValue {
                self.timeScaleView.timeSlider.setValue(NSNumber(value: value), animated: true)
            }
        }
    }
    
    private func resetShouldUpdateTimeSliderValue() {
        _shouldUpdateTimeSliderValue = false
    }
    
    private func findPlayerPosition(for time: UInt) -> PlayerPosition? {
        guard let infoList = _videoInfoList, infoList.count > 0 else {
            return nil
        }
        
        var rindex: UInt = 0
        var rtime: UInt = 0
        
        for i in 0..<infoList.count {
            let vi = infoList[i]
            let ct = vi!.info.creationTime
            if time < ct {
                if rindex != 0 && rindex != infoList.count - 1 {
                    rindex += 1
                }
                break
            } else if time >= ct && time < ct + vi!.info.duration {
                rindex = i
                rtime = time - ct
                break
            } else if time >= ct {
                rindex = i
                rtime = 0
            }
        }
        
        return PlayerPosition(index: rindex, time: rtime)
    }
    
    final func play(fromPlaylistAt itemIndex: UInt, startTime:UInt) {
//        resetShouldUpdateTimeSliderValue() cancel //??
        let success = _player.play(fromPlaylistAt: itemIndex, startTime: startTime)
//        _shouldUpdateTimeSliderValue = success //??
        if success {
//            resetShouldUpdateTimeSliderValue() delayed 2 //??
        }
    }
    
    private func skipPlaylistItem(_ direction: Int) {
        if _player.state == .stopped {
            return
        }
        
        let newIndex: Int = Int(_lastPosition.index) + direction
        guard let infoList = _videoInfoList else {
            return
        }
        
        if newIndex < 0 || newIndex >= infoList.count {
            return
        }
        
        let index = UInt(newIndex)
        _lastPosition.index = index
        let number = NSNumber(value: infoList[index]!.info.creationTime)
        self.timeScaleView.timeSlider.setValue(number, animated: true)
        self.play(fromPlaylistAt: index, startTime: 0)
    }
    
    private func skipNextPlaylistItem() {
        skipPlaylistItem(+1)
    }
    
    private func skipPrevPlaylistItem() {
        skipPlaylistItem(-1)
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
