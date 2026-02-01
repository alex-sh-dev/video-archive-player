//
//  VideoScrollView.swift
//  VideoArchivePlayer
//
//  Created by dev on 2/1/26.
//

import UIKit

class VideoScrollView : EXScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultConfigure()
    }
    
    private func defaultConfigure() {
        self.minimumZoomScale = 1
        self.maximumZoomScale = 2
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.contentInsetAdjustmentBehavior = .never
        self.stickToBounds = true
    }
}
