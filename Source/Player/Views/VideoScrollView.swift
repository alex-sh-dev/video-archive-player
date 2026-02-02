//
//  VideoScrollView.swift
//  VideoArchivePlayer
//
//  Created by dev on 2/1/26.
//

import UIKit

final class VideoScrollView : EXScrollView, UIScrollViewDelegate {
    // MARK: public outlets
    
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var zoomingView: ZoomingView!
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultConfigure()
    }
    
    // MARK: private functions
    
    private func defaultConfigure() {
        self.minimumZoomScale = 1
        self.maximumZoomScale = 2
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.contentInsetAdjustmentBehavior = .never
        self.stickToBounds = true
        self.delegate = self
    }
    
    // MARK: public functions
    
    public func specifyVideoSize(_ videoSize: CGSize) {
        if videoSize.equalTo(CGSizeZero) {
            return
        }
        
        let scale = UIScreen.main.scale
        var vs = videoSize
        
        vs.height = (vs.height / scale).rounded(.down)
        vs.width = (vs.width / scale).rounded(.down)
        
        self.videoView.initialVideoSize = vs
        
        let ss = UIScreen.main.bounds.size
        var newSize = CGSize(width: CGFloat.maximum(ss.height, ss.width),
                             height: CGFloat.minimum(ss.height, ss.width))
        
        if vs.width < newSize.width {
            let p = vs.height / vs.width
            newSize.height = (vs.height + (newSize.width - vs.width) * p).rounded(.down)
            vs = CGSize(width: newSize.width, height: newSize.height)
        }
        
        self.zoomingView.bounds = CGRect(x: 0, y: 0, width: vs.width, height: vs.height)
        self.setNeedsReconfigure()
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomingView
    }
}
