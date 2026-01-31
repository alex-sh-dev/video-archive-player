//
//  ActivityIndicatorBackgroundView.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/23/26.
//

import UIKit

class ActivityIndicatorView: UIActivityIndicatorView {}

class ActivityIndicatorBackgroundView: UIView {
    weak var indicator: ActivityIndicatorView?
    private let kDefaultAlpha: CGFloat = 0.7
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            return
        }
        
        if !self.subviews.isEmpty {
            self.indicator = self.subviews.first(
                where: {$0 is ActivityIndicatorView}) as? ActivityIndicatorView
        }
        
        assert(self.indicator != nil)
        
        if !self.constraints.isEmpty,
            let constraint = self.constraints.first(
                where: {$0.identifier == "width"}) {
            let bounds = UIScreen.main.bounds
            constraint.constant = CGFloat.maximum(CGRectGetHeight(bounds), CGRectGetWidth(bounds))
        }
        
        self.isOpaque = false
        self.backgroundColor = UIColor.black
        self.alpha = kDefaultAlpha
        
        ActivityIndicatorView.appearance().color = UIColor.white
        ActivityIndicatorView.appearance().tintColor = UIColor.white
        self.indicator?.isOpaque = true
        self.indicator?.style = .medium
    }
}
