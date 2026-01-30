//
//  PlaylistVideoPlayer.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/27/26.
//

import UIKit
import MobileVLCKit

// MARK: enums

enum PlaylistVideoPlayerState: UInt {
    case stopped = 0
    case playing
    case paused
    case endReached
}

enum PlaylistItemIndex: Equatable {
    case first
    case last
    case unspecified
    case value(UInt)

    var rawValue: UInt {
        get {
            switch self {
            case .first:
                return 0
            case .last:
                return UInt.max
            case .unspecified:
                return UInt.max - 1
            case .value(let val):
                return val
            }
        }
    }
}

private enum MediaListIndex: Equatable {
    case last
    case notFound
    case value(UInt)

    static func == (lhs: MediaListIndex, rhs: MediaListIndex) -> Bool {
        switch (lhs, rhs) {
        case (.last, .last):
            return true
        case (.notFound, .notFound):
            return true
        case (.value(let lhsInd), .value(let rhsInd)):
            return lhsInd == rhsInd
        default:
            return false
        }
    }
}

// MARK: private classes

private class MediaInfo {
    enum FileLocation : UInt {
        case unknown = 0
        case onDevice
        case onServer
    }

    var startTime: UInt
    var location: FileLocation
    var filePath: String
    
    init(startTime: UInt, location: FileLocation, filePath: String) {
        self.startTime = startTime
        self.location = location
        self.filePath = filePath
    }
}

private class MediaItem {
    let media: VLCMedia?
    let index: UInt

    init(media: VLCMedia?, index: UInt) {
        self.media = media
        self.index = index
    }
}

// MARK: consts

private struct Constants {
    static let kDefaultMediaListPlayerOptions = ["--no-stats"]
    static let kDefaultMediaPlayerPosition = -1
    static let kDefaultOptionsToDisableAudio = [":no-audio" : 1, ":no-sout-audio" : 1]
    static let kCacheOptions = ["network-caching": 1000]
}

final class PlaylistVideoPlayer: NSObject, VLCMediaPlayerDelegate, VLCMediaListPlayerDelegate {
    // MARK: public properties
    weak var delegate: PlaylistVideoPlayerDelegate?

    var playlistCount: Int {
        get {
            return _mediaList.count
        }
    }

    var currentPosition: Int {
        get {
            return _playerPosition
        }
    }

    var state: PlaylistVideoPlayerState {
        get {
            return _state
        }
    }
    
    // MARK: private properties
    
    private let _mediaListPlayer: VLCMediaListPlayer = VLCMediaListPlayer(options:Constants.kDefaultMediaListPlayerOptions)
    private let _mediaList: VLCMediaList = VLCMediaList(array: [])
    private weak var _videoView: UIView?
    
    private var _state: PlaylistVideoPlayerState = .stopped
    private var _audioDisabled: Bool = false
    private var _playerPosition: Int  = Constants.kDefaultMediaPlayerPosition
    
    // MARK: private functions
    
    private func setState(newState: PlaylistVideoPlayerState) {
        _state = newState
    }
    
    private func configure() {
        VLCLibrary.shared().debugLogging = false
        _mediaListPlayer.delegate = self
        _mediaListPlayer.mediaPlayer?.delegate = self
        _mediaListPlayer.repeatMode = .doNotRepeat
    }
    
    private func clearMediaList() {
        _mediaList.lock()
        while _mediaList.count != 0 {
            _mediaList.media(at: 0)?.releaseObject(type: MediaInfo.self)
            let success = _mediaList.removeMedia(at: 0)
            assert(success)
        }
        assert(_mediaList.count == 0)
        _mediaList.unlock()
    }
    
    private func locateMediaFile(filePath: String) -> MediaInfo.FileLocation {
        if filePath.isEmpty {
            return .unknown
        }
        
        let loc: MediaInfo.FileLocation
        if let url = URL(string: filePath), let _ = url.host {
            switch url.scheme {
            case "http", "https":
                loc = .onServer
            default:
                loc = .unknown
            }
        } else {
            loc = .onDevice
        }
        
        return loc
    }
    
    private func createMedia(filePath: String) -> VLCMedia? {
        let loc = locateMediaFile(filePath: filePath)
        var media: VLCMedia?
        switch (loc) {
        case .onServer:
            let url = URL(string: filePath)
            media = VLCMedia(url: url!)
        case .onDevice:
            media = VLCMedia(path: filePath)
        default:
            media = nil
        }
        let mi = MediaInfo(startTime: 0, location: loc, filePath: filePath)
        media?.setObject(object: mi)

        return media
    }
    
    private func appendMedia(media: VLCMedia, options:[String: Any] = [:]) {
        if _audioDisabled {
            media.addOptions(Constants.kDefaultOptionsToDisableAudio)
        }
        
        if !options.isEmpty {
            media.addOptions(options)
        }
        
        _mediaList.lock()
        _mediaList.add(media)
        _mediaList.unlock()
    }
    
    private func getMediaListIndex(for media: VLCMedia?) -> MediaListIndex {
        if media == nil {
            return .notFound
        }
        
        _mediaList.lock()
        let itemIndex: UInt = _mediaList.index(of: media)
        let count: Int = _mediaList.count
        _mediaList.unlock()
        
        if itemIndex == NSNotFound {
            return .notFound
        }
        
        if itemIndex == count - 1 {
            return .last
        } else {
            return .value(itemIndex)
        }
    }
    
    private func currentPlayerMedia() -> MediaItem? {
        guard let media = _mediaListPlayer.mediaPlayer?.media else {
            return nil
        }
        _mediaList.lock()
        let itemIndex = _mediaList.index(of: media)
        _mediaList.unlock()
        
        if itemIndex == NSNotFound {
            return nil
        }
        
        return MediaItem(media: media, index: itemIndex)
    }
    
    private func media(at itemIndex: PlaylistItemIndex) -> VLCMedia? {
        var media: VLCMedia?
        _mediaList.lock()
        let count = UInt(_mediaList.count)
        if (count > 0) {
            var index = itemIndex
            if itemIndex == .last {
                index = .value(count - 1)
            }
            if index.rawValue >= 0 && index.rawValue < count { //?? ok?
                media = _mediaList.media(at: index.rawValue)
            }
        }
        _mediaList.unlock()
        
        return media
    }
    
    private func canJump() -> Bool {
        return _state != .stopped
    }
    
    // MARK: init
    
    private func test() { //??

    }
    
    init(videoView: UIView) {
        super.init()
        _videoView = videoView
        configure()
        test()//??
    }
    
    // MARK: deinit
    
    deinit {
        clearMediaList()
        _mediaListPlayer.mediaPlayer?.delegate = nil
        _mediaListPlayer.delegate = nil
        _mediaListPlayer.stop()
    }
    
    // MARK: VLCMediaPlayerDelegate
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer else {
            return
        }
        
        assert(player == _mediaListPlayer.mediaPlayer)
            
        let state = player.state

        if state == .buffering {
            if let userInfo = aNotification.userInfo as? Dictionary<String, NSNumber> { //?? check
                var completeness = 0
                if let cache = userInfo["cache"] {
                    completeness = cache.intValue
                }
                
                if completeness == 0 {
                    self.delegate?.playerHasStartedBuffering(player: self)
                } else if completeness == 100 {
                    self.delegate?.playerHasCompletedBuffering(player: self)
                }
            }
        }
        
        if player.isPlaying && _state != .playing {
            setState(newState: .playing)
            self.delegate?.playerPlaying(player: self)
        }
        
        switch (state) {
        case .playing:
            break
        case .paused:
            setState(newState: .paused)
            self.delegate?.playerPaused(player: self)
        case .stopped:
            let state = _mediaListPlayer.state()
            let index = getMediaListIndex(for: player.media)
            if (state == .error || state == .ended) && index != .notFound {
                if !(state == .ended && index == .last) {
                    if !_mediaListPlayer.next {
                        _mediaListPlayer.stop()
                    }
                }
            } else {
                setState(newState: .stopped)
                self.delegate?.playerStopped(player: self)
            }
        case .ended:
            let index = getMediaListIndex(for: player.media)
            switch (index) {
            case .notFound:
                break
            case .last:
                setState(newState: .endReached)
                self.delegate?.playerEndReached(player: self)
            case .value(let index):
                self.delegate?.playerItemEndReached(player: self, itemIndex: index)
            }
        case .error:
            self.delegate?.playerErrorEncountered(player: self)
        default:
            break
        }
    }
    
    func mediaPlayerPositionChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer else {
            return
        }
        
        assert(player == _mediaListPlayer.mediaPlayer)
        
        self.delegate?.playerPositionChanged(player: self)
        
        let pos = player.directTime != VLCTime.null() ? Int(player.directTime.intValue / 1000) : 0 //?? cast ок?
        assert(pos >= 0)
        if let mediaItem = currentPlayerMedia(), pos != _playerPosition { //?? check pass to {}
            self.delegate?.playerPositionChangedAtItem(palyer: self, pos: UInt(pos), itemIndex: mediaItem.index)
        }
        _playerPosition = pos
    }
    
    // MARK: VLCMediaListPlayerDelegate
    
    func mediaListPlayer(_ player: VLCMediaListPlayer!, nextMedia media: VLCMedia!) {
        assert(player == _mediaListPlayer)
        self.delegate?.playerNextItemSet(player: self)
        
        _playerPosition = Constants.kDefaultMediaPlayerPosition

        guard let mediaItem = currentPlayerMedia() else {
            return
        }
        
        guard let mi: MediaInfo = mediaItem.media?.object() else {
            return
        }
        
        let location = mi.location
        let filePath = mi.filePath
        let startTime = mi.startTime
        
        if location != .unknown && !filePath.isEmpty && startTime != NSNotFound {
            var exists = false
            switch (location) {
            case .onDevice:
                exists = FileManager.default.fileExists(atPath: filePath)
            case .onServer:
                guard let url = URL(string: filePath) else {
                    break
                }
                exists = existsRemoteFile(url: url)
            default:
                break
            }

            if (exists) {
                self.delegate?.playerNextItemSet(player: self, startTime: startTime)
            } else {
                if !_mediaListPlayer.next {
                    _mediaListPlayer.stop()
                }
                self.delegate?.playerFileCeasedExistence(player: self, filePath: filePath, itemIndex: mediaItem.index)
            }
        }
    }
    
    // MARK: public functions
    
    final func setFile(_ filePath: String) {
        setFiles([filePath])
    }
    
    final func setFiles(_ filePaths: [String]) {
        clearMediaList()
        for filePath in filePaths {
            if filePath.isEmpty {
                continue
            }
            
            guard let media = createMedia(filePath: filePath) else {
                continue
            }
            
            if locateMediaFile(filePath: filePath) == .onServer {
                appendMedia(media: media, options: Constants.kCacheOptions)
            } else {
                appendMedia(media: media)
            }
        }
    }
    
    final func play(startingFrom itemIndex: PlaylistItemIndex = .unspecified) {
        var play = false
        switch (_state) {
        case .paused:
            play = true
        case .stopped:
            _mediaListPlayer.mediaList = _mediaList
            _mediaListPlayer.mediaPlayer.drawable = _videoView
            play = true
        default:
            break
        }
        
        if !play {
            return
        }
    
        if itemIndex == .unspecified || _state == .paused {
            _mediaListPlayer.play()
        } else {
            if let media = media(at: itemIndex) {
                _mediaListPlayer.play(media)
            } else {
                _mediaListPlayer.play()
            }
        }
    }

    final func play(withFile filePath: String) {
        setFile(filePath)
        play()
    }

    final func play(fromPlaylistAt itemIndex: UInt, startTime:UInt) -> Bool {
        if _state == .stopped {
            return false
        }
        
        guard let media = _mediaList.media(at: itemIndex) else {
            return false
        }
        
        let mi: MediaInfo = media.object()
        mi.startTime = startTime
        let pos = VLCTime(number: NSNumber(value: Int(startTime) * 1000)) //?? check creation and passing pos
        _mediaListPlayer.playItemIndex(Int32(itemIndex), inPosition: pos)
        return true
    }
    
    final func play(withPaths filePaths: [String], startingFrom itemIndex: PlaylistItemIndex = .first) {
        setFiles(filePaths)
        play(startingFrom: itemIndex)
    }
    
    final func shortJumpForward() {
        if canJump() {
            _mediaListPlayer.mediaPlayer.shortJumpForward()
        }
    }
    
    final func shortJumpBackward() {
        if canJump() {
            _mediaListPlayer.mediaPlayer.shortJumpBackward()
        }
    }

    final func longJumpForward() {
        if canJump() {
            _mediaListPlayer.mediaPlayer.longJumpForward()
        }
    }
    
    final func longJumpBackward() {
        if canJump() {
            _mediaListPlayer.mediaPlayer.longJumpBackward()
        }
    }

    final func stop() {
        _mediaListPlayer.stop()
        clearMediaList()
    }
    
    final func pause() -> Bool {
        if _mediaListPlayer.isPlaying() {
            _mediaListPlayer.pause()
            return true
        }
        
        return false
    }
    
    final func disableAudio(disabled: Bool) {
        _audioDisabled = disabled
    }

    final func append(toPlaylist filePath: String) {
        if filePath.isEmpty {
            return
        }
        
        guard let media = createMedia(filePath: filePath) else {
            return
        }
        
        if locateMediaFile(filePath: filePath) == .onServer {
            appendMedia(media: media, options: Constants.kCacheOptions)
        } else {
            appendMedia(media: media)
        }
    }
    
    final func remove(fromPlaylistAt index: UInt) {
        guard let mediaItem = currentPlayerMedia() else {
            return
        }
        
        if mediaItem.index == index {
            if !_mediaListPlayer.next {
                _mediaListPlayer.stop()
            }
        }
        
        _mediaList.lock()
        if let media = _mediaList.media(at: index) {
            media.releaseObject(type: MediaInfo.self)
            _mediaList.removeMedia(at: index)
        }
        _mediaList.unlock()
    }
}
