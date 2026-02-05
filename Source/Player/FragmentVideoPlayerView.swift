//
//  FragmentVideoPlayerView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/31/26.
//

import UIKit

private struct PlayerPosition {
    var itemIndex: PlaylistItemIndex = .first
    var time: UInt = 0
    
    init() {}
    
    init(itemIndex: PlaylistItemIndex, time: UInt) {
        self.itemIndex = itemIndex
        self.time = time
    }
}

private enum PlayButtonIdentity: Int {
    case play = 0
    case pause
}

private struct Constants {
    static let kFastForwardValue = +30
    static let kRewindValue = -30
    
    static let kMinVideoSpeed = 25
    static let kMaxVideoSpeed = 200
    static let kVideoSpeedStep = 25
    static let kNormalVideoSpeed = 100
}

final class FragmentVideoPlayerView: UIView, PlaylistVideoPlayerDelegate,
                                     VideoViewDelegate, TimeScaleViewDelegate
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
    
    var toolsHidden: Bool {
        return self.mainButtonGroup.isHidden
    }
    
    weak var delegate: FragmentVideoPlayerViewDelegate?
    
    // MARK: private properties
    
    private weak var contentView: UIView!
    private var _player: PlaylistVideoPlayer!
    
    private var _videoInfoList: VideoFileList?
    
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
            if self.playButton.tag == PlayButtonIdentity.play.rawValue {
                self.startPlayer()
            } else {
                self.pausePlayer()
            }
        case self.fastForwardButton:
            self.skipTimeSliderValue(Constants.kFastForwardValue)
        case self.rewindButton:
            self.skipTimeSliderValue(Constants.kRewindValue)
        case self.skipNextButton:
            skipNextPlaylistItem()
        case self.skipPrevButton:
            skipPrevPlaylistItem()
        case self.speedButton:
            changeVideoSpeed()
        default:
            break
        }
    }
    
    // MARK: private functions
    
    private func customInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self).first as! UIView
        self.contentView = view
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
        
        self.videoScrollView.videoView.delegate = self
        self.timeScaleView.delegate = self
        self.timeScaleView.timeSlider.isUserInteractionEnabled = false
        
        updateVideoSpeed(Constants.kNormalVideoSpeed)
        
        showPlayButton()
    }
    
    private func createPlayer(audioDisabled: Bool = true) {
        if _player != nil {
            return
        }
        
        videoScrollView.isUserInteractionEnabled = false
        _player = PlaylistVideoPlayer(videoView:self.videoScrollView.videoView, noAudio: audioDisabled)
        _player.delegate = self
        updateVideoSpeed(self.speedButton.tag)
    }
    
    private func playerStopped() -> Bool {
        return _player == nil || _player.state == .stopped
    }
    
    private func showPlayButton() {
        if self.playButton.tag == PlayButtonIdentity.play.rawValue {
            return
        }
        
        let image = UIImage(systemName: "play.fill")
        self.playButton.setImage(image, for: .normal)
        self.playButton.tag = PlayButtonIdentity.play.rawValue
    }
    
    private func showPauseButton() {
        if self.playButton.tag == PlayButtonIdentity.pause.rawValue {
            return
        }
        
        let image = UIImage(systemName: "pause.fill")
        self.playButton.setImage(image, for: .normal)
        self.playButton.tag = PlayButtonIdentity.pause.rawValue
    }
    
    private func updateVideoSpeed(_ speed: Int) {
        self.speedButton.tag = speed
        let fspeed = Float(speed) / 100.0
        
        self.speedButton.setTitle(String(fspeed), for: .normal)
        _ = _player?.setVideoSpeed(fspeed)
    }
    
    private func changeVideoSpeed() {
        var speed = self.speedButton.tag + Constants.kVideoSpeedStep
        if speed > Constants.kMaxVideoSpeed {
            speed = Constants.kMinVideoSpeed
        }
        updateVideoSpeed(speed)
    }
    
    private func startPlayer(itemIndex: PlaylistItemIndex = .unspecified) {
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
            guard let infoList = _videoInfoList, !infoList.isEmpty else {
                return
            }
            
            var creationTime: UInt = 0
            var newItemIndex: PlaylistItemIndex = .first
            let count = infoList.count
            if itemIndex == .last {
                newItemIndex = .value(count - 1)
                creationTime = infoList.last!.info.creationTime
            } else if itemIndex.rawValue >= 0 && itemIndex.rawValue < count {
                newItemIndex = itemIndex
                creationTime = infoList[itemIndex.rawValue]!.info.creationTime
            }
            
            _player.play(withFiles: infoList.paths, startingFrom: newItemIndex)
            _lastPosition.itemIndex = newItemIndex
            self.timeScaleView.setTimeSliderValue(NSNumber(value: creationTime))
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
        _player?.stop()
    }
    
    private func calcAndSetTimeSliderValue(itemIndex: PlaylistItemIndex, time: UInt) {
        if !_playerSuspended {
            _lastPosition = PlayerPosition(itemIndex: itemIndex, time: time)
        }
        
        if (self.timeScaleView.timeSlider.isThumbCaptured || self.timeScaleView.imitationCaptured) {
            return
        }
        
        guard let infoList = _videoInfoList, !infoList.isEmpty else {
            return
        }
        
        if let vi = infoList[itemIndex.rawValue] {
            let value = vi.info.creationTime + time
            if value <= TimeSlider.kMaxValue {
                self.timeScaleView.setTimeSliderValue(NSNumber(value: value), animated: true)
            }
        }
    }
    
    private func playerPosition(for time: UInt) -> PlayerPosition? {
        guard let infoList = _videoInfoList, !infoList.isEmpty else {
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
        
        return PlayerPosition(itemIndex: .value(rindex), time: rtime)
    }
    
    private func skipPlaylistItem(_ direction: Int) {
        if playerStopped() {
            return
        }
        
        let newIndex: Int = Int(_lastPosition.itemIndex.rawValue) + direction
        guard let infoList = _videoInfoList else {
            return
        }
        
        if newIndex < 0 || newIndex >= infoList.count {
            return
        }
        
        let index = UInt(newIndex)
        _lastPosition.itemIndex = .value(index)
        let number = NSNumber(value: infoList[index]!.info.creationTime)
        self.timeScaleView.setTimeSliderValue(number, animated: true)
        self.play(fromPlaylistAt: .value(index), startTime: 0)
    }
    
    private func skipNextPlaylistItem() {
        skipPlaylistItem(+1)
    }
    
    private func skipPrevPlaylistItem() {
        skipPlaylistItem(-1)
    }
    
    private func skipTimeSliderValue(_ time: Int) {
        if playerStopped() {
            return
        }
            
        var newValue = self.timeScaleView.timeSlider.value.intValue + time
        if newValue < TimeSlider.kMinValue {
            newValue = TimeSlider.kMinValue
        } else if newValue > TimeSlider.kMaxValue {
            newValue = TimeSlider.kMaxValue
        }
        
        self.timeScaleView.setTimeSliderValue(NSNumber(value: newValue), delayedEventStart: true)
    }
    
    private func play(fromPlaylistAt itemIndex: PlaylistItemIndex, startTime:UInt) {
        self.timeScaleView.performSimulatedCapture() {
            _player.play(fromPlaylistAt: itemIndex, startTime: startTime)
        }
    }
    
    // MARK: public functions
    
    func suspendPlayer() {
        if playerStopped() {
            return
        }
        
        stopPlayer()
        _playerSuspended = true
    }
    
    func restorePlayer() -> Bool {
        if _playerSuspended {
            startPlayer(itemIndex: _lastPosition.itemIndex)
            return true
        }
        
        return false
    }
    
    func startPlayer(videoFileList: VideoFileList, videoSize: CGSize = .zero,
                     audioDisabled: Bool = true, startTime: UInt = 0) {
        if videoFileList.count == 0 {
            return
        }
        
        stopPlayer()
        
        _videoInfoList = videoFileList
        
        var timeIntervals: [TimeInterval] = []
        for i in 0..<videoFileList.count {
            let vfi = videoFileList[i]!.info
            let ti = TimeInterval(start: vfi.creationTime, length: vfi.duration)
            timeIntervals.append(ti)
        }

        if !timeIntervals.isEmpty {
            self.timeScaleView.timeSlider.timeIntervals = timeIntervals
            self.timeScaleView.setNeedsDisplay()
        }
    
        var foundItemIndex: PlaylistItemIndex = .first
        if startTime >= TimeSlider.kMinValue
            && startTime < TimeSlider.kMaxValue {
            if let pos = playerPosition(for: startTime) {
                foundItemIndex = pos.itemIndex
                _lastPosition = pos
                _needsRestorePosition = true
            }
        }
        
        self.createPlayer(audioDisabled: audioDisabled)
        self.videoScrollView.specifyVideoSize(videoSize)
        self.startPlayer(itemIndex: foundItemIndex)
    }
    
    func hideTools(_ hidden: Bool) {
        self.timeScaleView.isHidden = hidden
        self.mainButtonGroup.isHidden = hidden
        self.extraButtonGroup.isHidden = hidden
    }
    
    // MARK: TimeScaleViewDelegate
    
    func timeSliderSetValueAfterDelay(slider: TimeSlider, value: UInt) {
        if _player.state == .stopped {
            return
        }
        
        if value == TimeSlider.kMaxValue {
            self.play(fromPlaylistAt: .last, startTime: 0)
            return
        } else if value == TimeSlider.kMinValue {
            self.play(fromPlaylistAt: .first, startTime: 0)
            return
        }
        
        if let pos = playerPosition(for: value) {
            self.play(fromPlaylistAt: pos.itemIndex, startTime: pos.time)
        }
    }
    
    // MARK: VideoViewDelegate
    
    func videoViewTapped() {
        self.delegate?.videoViewTapped()
    }
    
    // MARK: PlaylistVideoPlayerDelegate
    
    func playerPlaying(player: PlaylistVideoPlayer) {
        if self.playButton.tag == PlayButtonIdentity.pause.rawValue {
            return
        }
        
        self.timeScaleView.isUserInteractionEnabled = true
        if (_playerSuspended || _needsRestorePosition)
            && _lastPosition.itemIndex.rawValue >= 0 && _lastPosition.time > 0 {
            self.play(fromPlaylistAt: _lastPosition.itemIndex, startTime: _lastPosition.time)
        }
        
        _playerSuspended = false
        _needsRestorePosition = false
        
        self.videoScrollView.isUserInteractionEnabled = true
        showPauseButton()
    }
    
    func playerReadyVideoSize(player: PlaylistVideoPlayer, videoSize: CGSize) {
        self.videoScrollView.specifyVideoSize(videoSize)
    }

    func playerPaused(player: PlaylistVideoPlayer) {
        self.showPlayButton()
    }

    func playerStopped(player: PlaylistVideoPlayer) {
        showPlayButton()
        self.timeScaleView.setTimeSliderValue(self.timeScaleView.timeSlider.minimumValue, animated: true)
        self.timeScaleView.isUserInteractionEnabled = false
        self.activityIndicatorBackgroundView.isHidden = true
        self.videoScrollView.zoomScale = self.videoScrollView.minimumZoomScale
        self.videoScrollView.isUserInteractionEnabled = false
    }

    func playerPositionChangedAtItem(player: PlaylistVideoPlayer, pos: UInt, itemIndex: PlaylistItemIndex) {
        self.calcAndSetTimeSliderValue(itemIndex: itemIndex, time: pos)
    }
    
    func playerEndReached(player: PlaylistVideoPlayer) {
        self.showPlayButton()
    }
    
    func playerErrorEncountered(player: PlaylistVideoPlayer) {
        player.stop()
        showPlayButton()
    }
    
    func playerNextItemSet(player: PlaylistVideoPlayer, itemIndex: PlaylistItemIndex, startTime: UInt) {
        easyLog()
        self.calcAndSetTimeSliderValue(itemIndex: itemIndex, time: startTime)
    }
    
    func playerHasStartedBuffering(player: PlaylistVideoPlayer) {
        self.activityIndicatorBackgroundView.isHidden = false
    }
    
    func playerHasCompletedBuffering(player: PlaylistVideoPlayer) {
        self.activityIndicatorBackgroundView.isHidden = true
    }
}
