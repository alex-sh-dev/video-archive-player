//
//  ZoomingView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/23/26.
//

import UIKit

class ZoomingView: UIView {
    override var frame: CGRect {
        didSet {
            guard let videoView = self.superview?.subviews.last as? VideoView else {
                return
            }

            videoView.frame = frame

            guard let vlcVideoView = videoView.subviews.first else {
                return
            }

            vlcVideoView.contentScaleFactor = videoView.calcScaleFactor()
        }
    }
}
