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

enum PlaylistItemIndex: Comparable {
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

// MARK: consts

private struct Constants {
    static let kDefaultMediaListPlayerOptions = ["--no-stats", "--http-reconnect", "--network-caching=1000"]
    static let kDefaultMediaPlayerPosition = -1
    static let kDefaultOptionsToDisableAudio = ["--no-audio", "--no-sout-audio"]
    static let kMaxVideoSpeed: Float = 2.0
    static let kMinVideoSpeed: Float = 0.25
}

final class PlaylistVideoPlayer: NSObject, VLCMediaPlayerDelegate, VLCMediaListPlayerDelegate {
    // MARK: public properties
    weak var delegate: PlaylistVideoPlayerDelegate?

    var playlistCount: UInt {
        get {
            let count = _mediaList.count
            return  count > 0 ? UInt(count) : 0
        }
    }

    var state: PlaylistVideoPlayerState {
        get {
            return _state
        }
    }
    
    // MARK: private properties
    
    private var _mediaListPlayer: VLCMediaListPlayer!
    private let _mediaList: VLCMediaList = VLCMediaList(array: [])
    
    private var _state: PlaylistVideoPlayerState = .stopped
    private var _playerPosition: Int  = Constants.kDefaultMediaPlayerPosition
    
    // MARK: private functions
    
    private func setState(newState: PlaylistVideoPlayerState) {
        _state = newState
    }
    
    private func configure(drawable: UIView, noAudio: Bool = false) {
        var options: [String] = Constants.kDefaultMediaListPlayerOptions
        if noAudio {
            options.append(contentsOf: Constants.kDefaultOptionsToDisableAudio)
        }
        _mediaListPlayer = VLCMediaListPlayer(options: options)
#if DEBUG
        VLCLibrary.shared().debugLogging = true
        VLCLibrary.shared().debugLoggingLevel = 4
#else
        VLCLibrary.shared().debugLogging = false
#endif
        _mediaListPlayer.delegate = self
        _mediaListPlayer.mediaPlayer?.delegate = self
        _mediaListPlayer.mediaPlayer?.drawable = drawable
        _mediaListPlayer.mediaList = _mediaList
        _mediaListPlayer.repeatMode = .doNotRepeat
    }
    
    private func clearMediaList() {
        _mediaList.lock()
        defer {
            _mediaList.unlock()
        }
        while _mediaList.count != 0 {
            _mediaList.media(at: 0)?.releaseObject(type: MediaInfo.self)
            let success = _mediaList.removeMedia(at: 0)
            assert(success)
        }
        assert(_mediaList.count == 0)
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
        let index: UInt = _mediaList.index(of: media)
        let count: Int = _mediaList.count
        _mediaList.unlock()
        
        if index == NSNotFound {
            return .notFound
        }
        
        if index == count - 1 {
            return .last
        } else {
            return .value(index)
        }
    }
    
    private func currentPlayerMedia() -> (media: VLCMedia, itemIndex: PlaylistItemIndex)? {
        guard let media = _mediaListPlayer.mediaPlayer?.media else {
            return nil
        }
        _mediaList.lock()
        let index = _mediaList.index(of: media)
        _mediaList.unlock()
        
        if index == NSNotFound {
            return nil
        }
        
        return (media, .value(index))
    }
    
    private func media(at itemIndex: PlaylistItemIndex) -> (obj: VLCMedia, index: UInt)? {
        var media: VLCMedia? = nil
        _mediaList.lock()
        defer {
            _mediaList.unlock()
        }
        let count = self.playlistCount
        var index: UInt = itemIndex.rawValue
        if (count > 0) {
            if itemIndex == .last {
                index = count - 1
            }
            
            if index >= 0 && index < count {
                media = _mediaList.media(at: index)
            }
        }
        
        if media == nil {
            return nil
        }
        
        return (media!, index)
    }
    
    // MARK: init
    
    init(videoView: UIView, noAudio: Bool = false) {
        super.init()
        configure(drawable: videoView, noAudio: noAudio)
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
        easyLog("\(state)")

        if state == .buffering {
            if let userInfo = aNotification.userInfo as? Dictionary<String, NSNumber> {
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
            case .value(let val):
                self.delegate?.playerItemEndReached(player: self, itemIndex: .value(val))
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
        
        let pos = player.directTime != VLCTime.null() ? Int(player.directTime.intValue / 1000) : 0
        assert(pos >= 0)
        if let mediaItem = currentPlayerMedia(), pos != _playerPosition {
            self.delegate?.playerPositionChangedAtItem(player: self, pos: UInt(pos), itemIndex: mediaItem.itemIndex)
        }
        _playerPosition = pos
    }
    
    // MARK: VLCMediaListPlayerDelegate
    
    func mediaListPlayer(_ player: VLCMediaListPlayer!, nextMedia media: VLCMedia!) {
        easyLog()
        assert(player == _mediaListPlayer)
        self.delegate?.playerNextItemSet(player: self)
        
        _playerPosition = Constants.kDefaultMediaPlayerPosition

        guard let mediaItem = currentPlayerMedia() else {
            return
        }
        
        let mi: MediaInfo = mediaItem.media.object()
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
                self.delegate?.playerNextItemSet(player: self, itemIndex: mediaItem.itemIndex, startTime: startTime)
            } else {
                if !_mediaListPlayer.next {
                    _mediaListPlayer.stop()
                }
                self.delegate?.playerFileCeasedExistence(player: self, filePath: filePath, itemIndex: mediaItem.itemIndex)
            }
        }
    }
    
    // MARK: public functions
    
    func setFile(_ filePath: String) {
        setFiles([filePath])
    }
    
    func setFiles(_ filePaths: [String]) {
        clearMediaList()
        for filePath in filePaths {
            append(toPlaylist: filePath)
        }
    }
    
    func play(startingFrom itemIndex: PlaylistItemIndex = .unspecified) {
        var play = false
        switch (_state) {
        case .paused, .stopped:
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
                _mediaListPlayer.play(media.obj)
            } else {
                _mediaListPlayer.play()
            }
        }
    }

    func play(withFile filePath: String) {
        setFile(filePath)
        play()
    }

    func play(fromPlaylistAt itemIndex: PlaylistItemIndex, startTime:UInt) -> Bool {
        if _state == .stopped {
            return false
        }
        
        guard let media = media(at: itemIndex) else {
            return false
        }
        
        let mi: MediaInfo = media.obj.object()
        mi.startTime = startTime
        let pos = VLCTime(number: NSNumber(value: Int(startTime) * 1000))
        _mediaListPlayer.playItemIndex(Int32(media.index), inPosition: pos)
        return true
    }
    
    func play(withFiles filePaths: [String], startingFrom itemIndex: PlaylistItemIndex = .first) {
        setFiles(filePaths)
        play(startingFrom: itemIndex)
    }

    func stop() {
        _mediaListPlayer.stop()
        clearMediaList()
    }
    
    func pause() -> Bool {
        if _mediaListPlayer.isPlaying() {
            _mediaListPlayer.pause()
            return true
        }
        
        return false
    }

    func setVideoSpeed(_ speed: Float) -> Bool {
        if speed >= Constants.kMinVideoSpeed &&
            speed <= Constants.kMaxVideoSpeed {
            _mediaListPlayer.mediaPlayer?.rate = speed
            return true
        }

        return false
    }

    func append(toPlaylist filePath: String) {
        if filePath.isEmpty {
            return
        }
        
        guard let media = createMedia(filePath: filePath) else {
            return
        }
        
        appendMedia(media: media)
    }
    
    func remove(fromPlaylistAt itemIndex: PlaylistItemIndex) {
        if itemIndex == .unspecified {
            return
        }
        
        guard let mediaItem = currentPlayerMedia() else {
            return
        }
        
        if mediaItem.itemIndex == itemIndex
            && !_mediaListPlayer.next {
            _mediaListPlayer.stop()
        }
        
        if let media = media(at: itemIndex) {
            media.obj.releaseObject(type: MediaInfo.self)
            _mediaList.removeMedia(at: media.index)
        }
    }
}
