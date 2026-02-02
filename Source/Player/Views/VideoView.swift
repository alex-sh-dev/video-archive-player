//
//  VideoView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/23/26.
//

import UIKit

protocol VideoViewDelegate: AnyObject {
    func videoViewTapped()
}

extension VideoViewDelegate {
    func videoViewTapped() {}
}

final class VideoView: UIView {
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer! {
        didSet {
            if let scrollView = self.superview as? VideoScrollView {
                self.tapGestureRecognizer.require(
                    toFail: scrollView.doubleTapGestureRecognizer)
            }
        }
    }
    
    weak var delegate: VideoViewDelegate?
    
    var initialVideoSize: CGSize = CGSizeZero
    private let expectedVideoView = "VLCOpenGLES2VideoView"
    
    @IBAction func tapped(_ sender: Any) {
        self.delegate?.videoViewTapped()
    }
    
    final func calcScaleFactor() -> CGFloat {
        let fs = self.frame.size
        let ivs = self.initialVideoSize
        let defScale = UIScreen.main.scale

        if ivs.equalTo(CGSizeZero) {
            return defScale
        }

        if fs.height > ivs.height && fs.width > ivs.width {
            let fh = ivs.height / fs.height
            let fw = ivs.width / fs.width
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
