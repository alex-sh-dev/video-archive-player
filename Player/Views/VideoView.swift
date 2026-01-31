//
//  VideoView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/23/26.
//

import UIKit

class VideoView: UIView {
    var originalVideoSize: CGSize = CGSizeZero
    private let expectedVideoView = "VLCOpenGLES2VideoView"
    
    final func calcScaleFactor() -> CGFloat {
        let fs = self.frame.size
        let ovs = self.originalVideoSize
        let defScale = UIScreen.main.scale

        if CGSizeEqualToSize(ovs, CGSizeZero) {
            return defScale
        }

        if fs.height > ovs.height && fs.width > ovs.width {
            let fh = ovs.height / fs.height
            let fw = ovs.width / fs.width
            return CGFloat.maximum(fh, fw) * defScale
        }

        return defScale
    }

    override func didAddSubview(_ subview: UIView) {
        let strFromClass = String(describing: subview.self)
        assert(strFromClass.contains(expectedVideoView),
               "Video view is not \(expectedVideoView)")
        super.didAddSubview(subview)
        subview.contentScaleFactor = calcScaleFactor()
    }
}
