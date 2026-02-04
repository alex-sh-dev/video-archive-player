//
//  PlaylistVideoPlayerOptional.swift
//  VideoArchivePlayer
//
//  Created by dev on 2/4/26.
//

import Foundation

extension PlaylistVideoPlayerDelegate {
    func playerPlaying(player: PlaylistVideoPlayer) {}
    func playerPaused(player: PlaylistVideoPlayer) {}
    func playerStopped(player: PlaylistVideoPlayer) {}
    
    func playerPositionChanged(player: PlaylistVideoPlayer) {}
    func playerPositionChangedAtItem(player: PlaylistVideoPlayer, pos: UInt, itemIndex: PlaylistItemIndex) {}
    
    func playerEndReached(player: PlaylistVideoPlayer) {}
    func playerItemEndReached(player: PlaylistVideoPlayer, itemIndex: PlaylistItemIndex) {}
    
    func playerNextItemSet(player: PlaylistVideoPlayer) {}
    func playerNextItemSet(player: PlaylistVideoPlayer, itemIndex:PlaylistItemIndex, startTime: UInt) {}
    
    func playerErrorEncountered(player: PlaylistVideoPlayer) {}
    
    func playerFileCeasedExistence(player: PlaylistVideoPlayer, filePath: String, itemIndex: PlaylistItemIndex) {}
    
    func playerHasStartedBuffering(player: PlaylistVideoPlayer) {}
    func playerHasCompletedBuffering(player: PlaylistVideoPlayer) {}
}
