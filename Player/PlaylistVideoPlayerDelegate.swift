//
//  PlaylistVideoPlayerDelegate.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/27/26.
//

import Foundation

// MARK: protocol functions

protocol PlaylistVideoPlayerDelegate: AnyObject {
    func playerPlaying(player: PlaylistVideoPlayer)
    func playerPaused(player: PlaylistVideoPlayer)
    func playerStopped(player: PlaylistVideoPlayer)
    
    func playerPositionChanged(player: PlaylistVideoPlayer)
    func playerPositionChangedAtItem(palyer: PlaylistVideoPlayer, pos: UInt, itemIndex: UInt)
    
    func playerEndReached(player: PlaylistVideoPlayer)
    func playerItemEndReached(player: PlaylistVideoPlayer, itemIndex: UInt)
    
    func playerNextItemSet(player: PlaylistVideoPlayer)
    func playerNextItemSet(player: PlaylistVideoPlayer, startTime: UInt)
    
    func playerErrorEncountered(player: PlaylistVideoPlayer)
    
    func playerFileCeasedExistence(player: PlaylistVideoPlayer, filePath: String, itemIndex: UInt)
    
    func playerHasStartedBuffering(player: PlaylistVideoPlayer)
    func playerHasCompletedBuffering(player: PlaylistVideoPlayer)
}

// MARK: optional functions

extension PlaylistVideoPlayerDelegate {
    func playerPlaying(player: PlaylistVideoPlayer) {}
    func playerPaused(player: PlaylistVideoPlayer) {}
    func playerStopped(player: PlaylistVideoPlayer) {}
    
    func playerPositionChanged(player: PlaylistVideoPlayer) {}
    func playerPositionChangedAtItem(palyer: PlaylistVideoPlayer, pos: UInt, itemIndex: UInt) {}
    
    func playerEndReached(player: PlaylistVideoPlayer) {}
    func playerItemEndReached(player: PlaylistVideoPlayer, itemIndex: UInt) {}
    
    func playerNextItemSet(player: PlaylistVideoPlayer) {}
    func playerNextItemSet(player: PlaylistVideoPlayer, startTime: UInt) {}
    
    func playerErrorEncountered(player: PlaylistVideoPlayer) {}
    
    func playerFileCeasedExistence(player: PlaylistVideoPlayer, filePath: String, itemIndex: UInt) {}
    
    func playerHasStartedBuffering(player: PlaylistVideoPlayer) {}
    func playerHasCompletedBuffering(player: PlaylistVideoPlayer) {}
}
